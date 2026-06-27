<template>
  <div>
    <audio
      ref="audioElm"
      preload="auto"
      loop>
      <source
        :src="audioSrc"
        type="audio/mpeg"
      />
    </audio>

    <!-- Top toolbar: back button + play again -->
    <div
      v-if="gameStatus != 'mode_selection'"
      class="qm-toolbar"
    >
      <v-btn
        class="qm-back-btn"
        depressed
        small
        @click="backToHome()"
      >
        <v-icon left small>mdi-home-outline</v-icon>
        Home
      </v-btn>

      <v-btn
        v-if="gameStatus == 'complete' && !isProjector && (!isMultiPlayer || canStartNextGame)"
        class="qm-btn qm-btn-primary"
        depressed
        @click="startNewGame()"
      >
        <v-icon left>mdi-replay</v-icon>
        {{ isMultiPlayer ? nextGameLabel : 'Play Again' }}
      </v-btn>
    </div>

    <!-- ============================== Mode Selection ============================== -->
    <div v-if="gameStatus == 'mode_selection'">
      <div class="qm-hero">
        <span class="qm-eyebrow">Bible Characters &middot; 10 Questions or Less</span>
        <h1 class="qm-title">Can I read <em>your mind</em>?</h1>
        <p class="qm-subtitle">
          I'm thinking of a Bible character. Pick a mode below and let's see if you can figure out who I have in mind&mdash;solo, with friends, or hosting your own private room.
        </p>
      </div>

      <v-card class="qm-card qm-interactive mb-5">
        <div class="qm-mode-card-head">
          <span class="qm-mode-icon"><v-icon color="#facc15">mdi-account-circle-outline</v-icon></span>
          <div>
            <div class="qm-mode-title">Play Solo</div>
            <div class="qm-mode-sub">Quick session against the puzzle</div>
          </div>
        </div>
        <v-card-text>
          <v-select
            v-if="gameTypes.length > 1"
            v-model="roomGameType"
            :items="gameTypes"
            label="Game Type"
            outlined
            dense
            dark
          ></v-select>
          <v-btn
            class="qm-btn qm-btn-primary qm-btn-block"
            depressed
            :disabled="!roomGameType"
            @click="startSoloGame()"
          >
            Start Solo Game
            <v-icon right>mdi-arrow-right</v-icon>
          </v-btn>
        </v-card-text>
      </v-card>

      <v-card class="qm-card qm-interactive qm-anim-2 mb-5">
        <div class="qm-mode-card-head">
          <span class="qm-mode-icon"><v-icon color="#a78bfa">mdi-account-group-outline</v-icon></span>
          <div>
            <div class="qm-mode-title">Join Friends</div>
            <div class="qm-mode-sub">Hop into someone&apos;s private room</div>
          </div>
        </div>
        <v-card-text>
          <div v-if="roomKeyInvalid" class="qm-error-pill">
            <v-icon small color="#fecaca">mdi-alert-circle-outline</v-icon>
            Expired or invalid room key
          </div>
          <v-text-field
            v-model="roomKey"
            label="Room Key"
            hint="Not case sensitive"
            outlined
            counter
            maxlength="4"
            dark
          ></v-text-field>
          <v-text-field
            v-model="playerName"
            hint="Doesn't have to be your real name"
            label="Your Display Name"
            outlined
            counter
            maxlength="20"
            dark
          ></v-text-field>
          <v-btn
            class="qm-btn qm-btn-primary qm-btn-block"
            depressed
            :disabled="!roomKey || !playerName"
            @click="joinRoom()"
          >
            Join Private Room
            <v-icon right>mdi-login</v-icon>
          </v-btn>
        </v-card-text>
      </v-card>

      <v-card class="qm-card qm-interactive qm-anim-3">
        <div class="qm-mode-card-head">
          <span class="qm-mode-icon"><v-icon color="#f472b6">mdi-party-popper</v-icon></span>
          <div>
            <div class="qm-mode-title">Host a Party</div>
            <div class="qm-mode-sub">Create a private room and invite friends</div>
          </div>
        </div>
        <v-card-text>
          <v-btn
            class="qm-btn qm-btn-ghost qm-btn-block"
            depressed
            @click="setupRoom()"
          >
            Create a Private Room
            <v-icon right>mdi-arrow-top-right</v-icon>
          </v-btn>
        </v-card-text>
      </v-card>
    </div>

    <!-- ============================== Setup Room ============================== -->
    <v-card v-if="gameStatus == 'setup_room'" class="qm-card">
      <v-card-title>Set up your room</v-card-title>
      <v-card-text>
        <div v-if="roomCreateError" class="qm-error-pill">
          <v-icon small color="#fecaca">mdi-alert-circle-outline</v-icon>
          {{ roomCreateError }}
        </div>
        <v-select
          v-if="gameTypes.length > 1"
          v-model="roomGameType"
          :items="gameTypes"
          label="Game Type"
          outlined
          dense
          dark
        ></v-select>
        <v-text-field
          v-model="playerName"
          hint="Doesn't have to be your real name"
          label="Your Display Name"
          outlined
          counter
          maxLength="20"
          dark
        ></v-text-field>
        <v-text-field
          v-model="secondsPerTurn"
          label="Seconds Per Turn"
          maxLength="3"
          outlined
          dark
        ></v-text-field>
        <v-text-field
          v-model.number="totalGames"
          label="Number of Games"
          hint="Best of X — first to a majority wins the series"
          persistent-hint
          type="number"
          min="1"
          max="99"
          maxLength="2"
          outlined
          dark
        ></v-text-field>
        <v-checkbox
          v-model="projectorEnabled"
          label="Project a host view"
          hint="Your screen becomes a shared scoreboard; you host instead of play"
          persistent-hint
          dark
          class="mb-2"
        ></v-checkbox>
        <v-btn
          class="qm-btn qm-btn-primary qm-btn-block"
          depressed
          :disabled="!roomGameType"
          @click="startMulti()"
        >
          Open Room
          <v-icon right>mdi-key-variant</v-icon>
        </v-btn>
      </v-card-text>
    </v-card>

    <!-- ============================== Waiting for Players ============================== -->
    <div v-if="gameStatus == 'waiting_for_players'">
      <div class="qm-hero">
        <span class="qm-eyebrow">Private Room</span>
        <h1 class="qm-title">{{ roomHostName || 'Host' }}<em>'s Lobby</em></h1>
        <p class="qm-subtitle">Share this key with anyone you want to play with.</p>
      </div>

      <div class="qm-room-key">
        <small>Room Key</small>
        <strong>{{ roomKey }}</strong>
      </div>

      <v-card class="qm-card mb-5">
        <v-card-subtitle>Connected Players &middot; {{ roomPlayers.length }}</v-card-subtitle>
        <v-card-text>
          <div class="qm-roster">
            <div
              v-for="player in roomPlayers"
              :key="player.id"
              class="qm-roster-item"
            >
              <span class="qm-player-avatar">{{ playerInitial(player.name) }}</span>
              <span class="qm-player-name">{{ player.name }}</span>
            </div>
          </div>
        </v-card-text>
      </v-card>

      <v-btn
        v-if="isRoomHost"
        class="qm-btn qm-btn-primary qm-btn-block"
        depressed
        @click="startNewGame()"
      >
        Start the Game
        <v-icon right>mdi-play</v-icon>
      </v-btn>
    </div>

    <!-- ============================== Intro ============================== -->
    <v-card v-if="gameStatus == 'intro'" class="qm-card">
      <v-card-title>Can you read my mind?</v-card-title>
      <v-card-text>
        <p>
          I'm thinking of a Bible character from the list below.
          Can you guess who it is in <strong style="color:var(--qm-gold)">{{ maxQuestions }} questions or less</strong>?
          When you're ready I'll give you 3 questions to choose from&mdash;pick the one that helps narrow things down.
          Tap <em>Past Questions</em> to review what you've asked. Tap <em>Take a Guess</em> to view the character list.
          Heads up: guesses count as questions, so use them carefully!
        </p>

        <h3 style="font-family:'Fraunces',serif; font-weight:600; margin: 22px 0 10px; color: var(--qm-text);">
          Character List
        </h3>
        <div class="qm-intro-subjects">
          <span v-for="subject in subjects" :key="subject.name">{{ subject.name }}</span>
        </div>

        <v-btn
          class="qm-btn qm-btn-primary qm-btn-block"
          depressed
          @click="startGame()"
        >
          Ready to Go
          <v-icon right>mdi-arrow-right-circle</v-icon>
        </v-btn>
      </v-card-text>
    </v-card>

    <!-- ============================== Game In Progress / Complete ============================== -->
    <div v-if="['intro', 'mode_selection', 'setup_room', 'waiting_for_players'].indexOf(gameStatus) === -1">

      <!-- Projector / host view -->
      <host-view
        v-if="isProjector"
        :room-key="roomKey"
        :players="scoreboardPlayers"
        :game-status="gameStatus"
        :series-status="seriesStatus"
        :games-completed="gamesCompleted"
        :total-games="totalGames"
        :score-to-win="scoreToWinSeries"
        :my-turn-player-id="roomMyTurnPlayerId"
        :my-turn-player-name="roomMyTurnPlayerName"
        :turn-seconds-left="turnSecondsLeft"
        :seconds-per-turn="Number(secondsPerTurn)"
        :questions-left="questionsLeft"
        :asked-questions="askedQuestions"
        :message="message"
        :banner-class="statusClass"
        @start-next-game="startNewGame()"
      ></host-view>

      <template v-else>
      <!-- Multiplayer turn indicator -->
      <div
        v-if="isMultiPlayer && ['in_progress', 'complete'].indexOf(gameStatus) > -1"
        :class="['qm-turn', myTurn ? 'qm-turn-mine' : '']"
      >
        <div class="qm-timer-ring" v-if="gameStatus == 'in_progress'">
          <svg viewBox="0 0 56 56">
            <circle class="qm-timer-track" cx="28" cy="28" r="24"></circle>
            <circle
              class="qm-timer-progress"
              cx="28" cy="28" r="24"
              :stroke-dasharray="timerCircumference"
              :stroke-dashoffset="timerOffset"
            ></circle>
          </svg>
          <span class="qm-timer-label">{{ Math.max(0, Math.ceil(turnSecondsLeft)) }}</span>
        </div>
        <div class="qm-turn-text">
          <small>Currently</small>
          {{ myTurn ? 'Your turn' : `${roomMyTurnPlayerName}'s turn` }}
        </div>
      </div>

      <!-- Status banner -->
      <v-card
        flat
        :class="['qm-status', statusClass, questionsLeftVariant]"
      >
        <span v-if="message">{{ message }}</span>
        <span v-else-if="questionsLeft > 1" class="qm-questions-left">
          <span class="qm-count">{{ questionsLeft }}</span>
          <span>questions left</span>
        </span>
        <span v-else>Time to take a guess!</span>
      </v-card>

      <!-- Main game card -->
      <v-card class="qm-card qm-game-board">
        <div class="qm-zone-main">
          <!-- Question Options -->
          <div v-if="gameStatus == 'in_progress' && questionsLeft > 1">
            <v-card-subtitle>Pick one question</v-card-subtitle>
            <div class="qm-section-body">
              <div class="qm-questions">
                <button
                  v-for="(question, index) in question_options"
                  :key="question.id"
                  :class="['qm-question-tile', question.disabled ? 'qm-q-disabled' : '']"
                  :disabled="question.disabled"
                  @click="selectQuestion(index)"
                >
                  <span class="qm-q-num">{{ index + 1 }}</span>
                  <span>{{ question.question }}?</span>
                </button>
              </div>
            </div>
          </div>

          <!-- Win/Lose celebration -->
          <div
            v-else-if="gameStatus == 'complete' && guessedSubjectIds.includes(correctSubjectId)"
            class="qm-result"
          >
            <div class="qm-confetti">
              <span v-if="askedQuestions.length / maxQuestions > 0.8">{{ '\u{1F60C}' }}</span>
              <span v-else-if="askedQuestions.length / maxQuestions > 0.5">{{ '\u{1F44F}' }}</span>
              <span v-else>{{ '\u{1F31F}' }}</span>
            </div>
            <h2 v-if="askedQuestions.length / maxQuestions > 0.8">
              Whew! Just made it in {{askedQuestions.length}} questions.
            </h2>
            <h2 v-else-if="askedQuestions.length / maxQuestions > 0.5">
              {{askedQuestions.length}} questions&mdash;not bad at all.
            </h2>
            <h2 v-else>
              Unbelievable! Only {{askedQuestions.length}} questions?!
            </h2>
          </div>
        </div>

        <!-- Past Questions -->
        <div class="qm-section qm-zone-log">
          <v-btn
            class="qm-section-toggle"
            depressed
            @click="showAskedQuestions = !showAskedQuestions"
          >
            <span class="qm-section-label">
              <span class="qm-section-icon"><v-icon small>mdi-history</v-icon></span>
              Past Questions
              <span style="color: var(--qm-text-muted); font-weight:400; margin-left: 4px;">({{ askedQuestions.length }})</span>
            </span>
            <v-icon>{{ showAskedQuestions ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
          </v-btn>
          <v-expand-transition>
            <div v-show="showAskedQuestions || forceExpandSections" class="qm-section-body">
              <div class="qm-log-legend">
                <span class="qm-dot yes">Yes</span>
                <span class="qm-dot no">No</span>
                <span class="qm-dot maybe">Not sure</span>
              </div>
              <div class="qm-log">
                <div
                  v-for="question in askedQuestions"
                  :key="question.id"
                  :class="['qm-log-item', `qm-log-${logVariant(question.color)}`]"
                >
                  <span class="qm-log-marker"></span>
                  <span>{{ question.text }}?</span>
                </div>
                <div v-if="!askedQuestions.length" style="color: var(--qm-text-muted); padding: 4px 0;">
                  No questions asked yet.
                </div>
              </div>
            </div>
          </v-expand-transition>
        </div>

        <!-- Take a Guess (subject grid) -->
        <div class="qm-section qm-zone-guess">
          <v-btn
            class="qm-section-toggle"
            depressed
            @click="showSubjects = !showSubjects"
          >
            <span class="qm-section-label">
              <span class="qm-section-icon"><v-icon small>mdi-target</v-icon></span>
              Take a Guess
            </span>
            <v-icon>{{ showSubjects ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
          </v-btn>
          <v-expand-transition>
            <div v-show="showSubjects || forceExpandSections" class="qm-section-body">
              <div class="qm-subjects">
                <button
                  v-for="subject in subjects"
                  :key="subject.id"
                  :class="['qm-subject', correctSubjectId == subject.id ? 'qm-subject-correct' : '']"
                  :disabled="correctSubjectId != subject.id && (guessedSubjectIds.includes(subject.id) || gameStatus != 'in_progress')"
                  @click="correctSubjectId == subject.id ? null : makeGuess(subject.id, subject.name)"
                >
                  {{ subject.name }}
                </button>
              </div>
            </div>
          </v-expand-transition>
        </div>

        <!-- Players (multiplayer) -->
        <div v-if="isMultiPlayer" class="qm-section">
          <v-btn
            class="qm-section-toggle"
            depressed
            @click="showPlayers = !showPlayers"
          >
            <span class="qm-section-label">
              <span class="qm-section-icon"><v-icon small>mdi-account-group</v-icon></span>
              Players
              <span style="color: var(--qm-text-muted); font-weight:400; margin-left: 4px;">({{ roomPlayers.length }})</span>
            </span>
            <v-icon>{{ showPlayers ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
          </v-btn>
          <v-expand-transition>
            <div v-show="showPlayers" class="qm-section-body">
              <div class="qm-players">
                <div
                  v-for="player in roomPlayers"
                  :key="player.id"
                  :class="['qm-player-row', player.is_connected ? '' : 'qm-disconnected']"
                >
                  <span class="qm-player-avatar">{{ playerInitial(player.name) }}</span>
                  <div style="flex:1;">
                    <div class="qm-player-name">{{ player.name }}</div>
                    <div class="qm-player-status" v-if="!player.is_connected">disconnected</div>
                  </div>
                  <span class="qm-player-score">{{ player.score }}</span>
                </div>
              </div>
            </div>
          </v-expand-transition>
        </div>
      </v-card>
      </template>
    </div>

    <!-- ============================== Series Winner Reveal ============================== -->
    <series-reveal
      v-if="showReveal"
      :players="scoreboardPlayers"
      :winner-player-id="seriesWinnerId"
      :grand="isProjector"
    ></series-reveal>
  </div>
</template>

<script>
import axios from "axios";
import hostView from "./host-view.vue";
import seriesReveal from "./series-reveal.vue";

export default {
  components: { hostView, seriesReveal },
  data: () => ({
    maxQuestions: 10,
    gameTypes: [],
    roomGameType: '',
    gameStatus: 'mode_selection',
    gameId: null,
    isMultiPlayer: false,
    roomKey: '',
    roomKeyInvalid: false,
    roomCreateError: '',
    roomId: null,
    secondsPerTurn: 60,
    turnInterval: null,
    turnSecondsLeft: 60.0,
    expiredTurns: 0,
    totalGames: 1,
    projectorEnabled: false,
    isProjector: false,
    roomHostId: null,
    roomProjectorEnabled: false,
    seriesStatus: 'in_progress',
    seriesWinnerId: null,
    seriesWinnerName: '',
    gamesCompleted: 0,
    scoreToWinSeries: 1,
    roomHostName: '',
    isRoomHost: false,
    playerName: '',
    playerId: null,
    roomPlayers: [],
    roomMyTurnPlayerId: null,
    roomMyTurnPlayerName: null,
    answerValTextColors: ['green', 'red', 'amber'],
    answerValBgColors: ['green lighten-2', 'red lighten-1', 'amber lighten-2'],
    answerValText: ['Yes', 'No', 'Not sure'],
    message: '',
    question_options: [],
    showSubjects: false,
    showPlayers: false,
    subjects: [],
    guessedSubjectIds: [],
    correctSubjectId: -1,
    showAskedQuestions: false,
    askedQuestions: [],
    processing: false,
    guess: {},
    headerColor: 'white',
    isWideViewport: typeof window !== 'undefined' && window.innerWidth >= 1100
  }),
  created: function () {
    axios
      .get("/pick_subject/game_types")
      .then(response => {
        this.gameTypes = response.data.data;
        if (this.gameTypes.length == 1){
          this.roomGameType = this.gameTypes[0];
        }
      });
  },
  mounted() {
    this.handleResize();
    window.addEventListener('resize', this.handleResize);
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize);
    document.body.classList.remove('qm-solo-wide');
  },
  watch: {
    isSoloBoardWide: {
      immediate: true,
      handler(val) {
        if (typeof document !== 'undefined') {
          document.body.classList.toggle('qm-solo-wide', val);
        }
      }
    }
  },
  channels: {
    GameChannel: {
      connected(){
        this.reportConnected();
      },
      rejected() {},
      received(data) {
        switch(data.type){
          case 'question_processed':
            this.questionProcessed(data);
            break;
          case 'guess_processed':
            this.guessProcessed(data);
            break;
          case 'game_room_change':
            this.refreshRoom(data);
            break;
          case 'turn_expired':
            this.turnExpiredProcessed(data);
            break;
          default:
            break;
        }
      },
      disconnected() {}
    }
  },
  computed: {
    audioSrc(){
      return `${window.location.protocol}//${window.location.host}/welcome/audio?id=31ljk23tjkl235l`;
    },
    myTurn() {
      return this.roomMyTurnPlayerId == this.playerId;
    },
    questionsLeft() {
      return this.maxQuestions - this.askedQuestions.length - this.expiredTurns;
    },
    questionsLeftVariant() {
      if (this.message) return '';
      if (this.questionsLeft <= 2) return 'qm-danger';
      if (this.questionsLeft <= 4) return 'qm-warn';
      return '';
    },
    statusClass() {
      if (!this.message) return '';
      switch (this.headerColor) {
        case 'green lighten-2': return 'qm-msg-yes';
        case 'red lighten-1':   return 'qm-msg-no';
        case 'amber lighten-2': return 'qm-msg-maybe';
        case 'red':             return 'qm-msg-warn';
        default: return '';
      }
    },
    timerCircumference() {
      return 2 * Math.PI * 24;
    },
    timerOffset() {
      const pct = Math.max(0, Math.min(1, this.turnSecondsLeft / this.secondsPerTurn));
      return this.timerCircumference * (1 - pct);
    },
    isSoloBoard() {
      return !this.isMultiPlayer && ['in_progress', 'complete'].indexOf(this.gameStatus) > -1;
    },
    isSoloBoardWide() {
      return this.isSoloBoard && this.isWideViewport;
    },
    forceExpandSections() {
      return this.isSoloBoardWide;
    },
    seriesComplete() {
      return this.isMultiPlayer && this.seriesStatus === 'complete';
    },
    scoreboardPlayers() {
      // Exclude the projecting host (a non-playing MC) from standings.
      if (this.roomProjectorEnabled && this.roomHostId) {
        return this.roomPlayers.filter(p => p.id != this.roomHostId);
      }
      return this.roomPlayers;
    },
    showReveal() {
      return this.seriesComplete && this.scoreboardPlayers.length > 1;
    },
    canStartNextGame() {
      return this.isRoomHost && this.seriesStatus !== 'complete';
    },
    nextGameLabel() {
      if (this.gamesCompleted === 0) {
        return this.totalGames > 1 ? `Start Game 1 of ${this.totalGames}` : 'Start Game';
      }
      if (this.gamesCompleted >= this.totalGames && this.totalGames > 1) {
        return 'Start Sudden-Death Game';
      }
      return `Start Game ${this.gamesCompleted + 1} of ${this.totalGames}`;
    }
  },
  methods: {
    handleResize() {
      this.isWideViewport = typeof window !== 'undefined' && window.innerWidth >= 1100;
    },
    playerInitial(name) {
      if (!name) return '?';
      return name.trim().charAt(0).toUpperCase();
    },
    logVariant(color) {
      if (color === 'green') return 'yes';
      if (color === 'red') return 'no';
      return 'maybe';
    },
    backToHome() {
      this.$refs.audioElm.pause();

      this.playerName = '';
      this.roomKey = '';
      this.gameStatus='mode_selection';
    },
    toggleAudio(){
      if(this.$refs.audioElm.paused){
        this.$refs.audioElm.play();
      }
      else{
        this.$refs.audioElm.pause();
      }
    },
    joinRoom() {
      this.roomKeyInvalid = false;
      axios.
        post('/pick_subject/game_rooms/add_player/',
        {
          room_key: this.roomKey,
          player_name: this.playerName
        }).then(response => {
            if(response.data.status === "not_found") {
              this.roomKeyInvalid = true;
              this.roomKey = '';
            }
            else {
              const data = response.data.data;
              this.playerId = data.player_id;
              this.isMultiPlayer = true;

              this.$cable.subscribe({
                channel: "GameChannel",
                room_key: this.roomKey,
                player_id: this.playerId
              });
            }
        });
    },
    reportConnected() {
      this.$cable.perform({
        channel: "GameChannel",
        action: "report_connected"
      });
    },
    setupRoom() {
      this.roomCreateError = '';
      this.gameStatus = "setup_room";
    },
    startSoloGame() {
      this.playerName = 'SOLO';
      this.totalGames = 1;
      this.projectorEnabled = false;
      this.openRoom();
    },
    startMulti() {
      this.roomCreateError = '';
      this.isMultiPlayer = true;
      this.isRoomHost = true;
      this.openRoom();
      this.gameStatus = 'waiting_for_players';
    },
    openRoom() {
      axios
        .post("/pick_subject/game_rooms",
        {
          game_type: this.roomGameType,
          player_name: this.playerName,
          total_games: this.totalGames,
          projector_enabled: this.projectorEnabled,
          seconds_per_turn: this.secondsPerTurn
        })
        .then(response => {
          const data = response.data.data;

          this.roomId = data.game_room_id;
          this.roomKey = data.room_key;
          this.playerId = data.player_id;

          this.$cable.subscribe({
            channel: "GameChannel",
            room_key: this.roomKey,
            player_id: this.playerId
          });
        })
        .catch(e => {
          // Don't strand the host on a blank lobby with no explanation.
          console.error('Failed to create room', e);
          this.roomCreateError = "Couldn't open the room. Please try again.";
          this.gameStatus = 'setup_room';
        });
    },
    refreshRoom(data) {
      if (data.game_id && this.gameId != data.game_id) {
        this.initForNewGame();
        this.gameId = data.game_id;
        this.subjects = data.subjects;
        this.secondsPerTurn = data.seconds_per_turn;
        this.setTimerToNext();
      }

      this.roomPlayers = data.players;
      this.roomHostName = data.host_player_name;
      this.roomHostId = data.host_player_id;
      this.roomProjectorEnabled = !!data.projector_enabled;
      this.isProjector = !!data.projector_enabled && this.playerId == data.host_player_id;
      this.roomMyTurnPlayerId = data.my_turn_player_id;
      this.roomMyTurnPlayerName = data.my_turn_player_name;
      this.expiredTurns = data.expired_turn_count;
      this.applySeries(data, true);

      if(data.game_status) {
        this.gameStatus = data.game_status;
      }
      else if (this.gameStatus == 'mode_selection') {
        if(this.isMultiPlayer) {
          this.gameStatus = 'waiting_for_players';
        }
        else {
          this.startNewGame();
        }
      }

      if(!this.question_options?.length && data.current_questions?.length){
        this.question_options = data.current_questions;
      }
    },
    applySeries(data, immediate = false) {
      if (data.total_games != null) this.totalGames = Number(data.total_games);
      if (data.score_to_win != null) this.scoreToWinSeries = Number(data.score_to_win);
      if (data.games_completed != null) this.gamesCompleted = Number(data.games_completed);
      if (data.series_winner_player_id !== undefined) this.seriesWinnerId = data.series_winner_player_id;
      if (data.series_winner_name !== undefined) this.seriesWinnerName = data.series_winner_name;

      if (data.series_status) {
        if (data.series_status === 'complete' && !immediate) {
          // Let the per-game result land before the dramatic series reveal.
          setTimeout(() => { this.seriesStatus = 'complete'; }, 1800);
        } else {
          this.seriesStatus = data.series_status;
        }
      }
    },
    startNewGame() {
      this.$refs.currentTime = 0;

      this.$cable.perform({
        channel: "GameChannel",
        action: "start_new_game"
      });
    },
    selectQuestion(index) {
      if(!this.myTurn){
        this.warnNotMyTurn();
        return;
      }

      if(this.processing) return;
      this.processing = true;
      clearInterval(this.turnInterval);

      const question = this.question_options[index];
      this.disableOtherQuestions(question.id);

      this.$cable.perform({
        channel: "GameChannel",
        action: "process_question",
        data: {
          question_id: question.id
        },
      });
    },
    questionProcessed(data) {
      this.applySeries(data);
      this.disableOtherQuestions(data.question_id);

      const answerIndex = data.answer_val - 1;
      this.message = this.answerValText[answerIndex];
      this.headerColor = this.answerValBgColors[answerIndex];

      const questionLog =
        {
          text: data.question,
          id: data.question_id,
          color: this.answerValTextColors[answerIndex]
        };
      this.askedQuestions.push(questionLog);

      setTimeout(
        () =>
          {
            this.gameStatus = data.game_status;
            if(this.gameStatus == 'complete') {
              this.endGameWithoutSuccess(data.correct_subject_id);
            }
            else{
              this.message = '';
              this.headerColor = 'white';
              this.question_options = data.next_question_options;
              this.roomMyTurnPlayerId = data.my_turn_player_id;
              this.roomMyTurnPlayerName = data.my_turn_player_name;
              this.setTimerToNext();
            }
            this.processing = false;
          },
        !this.isMultiPlayer || this.myTurn ? 1000 : 2000
        );
    },
    disableOtherQuestions(questionId){
      this.question_options.forEach((q) => {
        if(q.id != questionId){
          q.disabled = true;
        }
      });
    },
    makeGuess(subjectId) {
      if(!this.myTurn){
        this.warnNotMyTurn();
        return;
      }

      if(this.processing) return;

      clearInterval(this.turnInterval);

      this.processing = true;
      this.guessedSubjectIds.push(subjectId);

      this.$cable.perform({
        channel: "GameChannel",
        action: "process_guess",
        data: {
          subject_id: subjectId
        },
      });
    },
    guessProcessed(data) {
      this.applySeries(data);
      this.gameStatus = data.game_status;
      this.correctSubjectId = data.correct_subject_id

      if(data.answer_val == 1){
        this.endGameWithSuccess(data);
      }
      else if(data.answer_val == 2){
        this.message = `Not ${data.name}`;
        this.headerColor = this.answerValBgColors[1];
        setTimeout(
        () =>
          {
            if(this.gameStatus == 'complete'){
              this.endGameWithoutSuccess(data.correct_subject_id);
            }
            else{
              this.message = '';
              this.headerColor = 'white';
              this.roomMyTurnPlayerId = data.my_turn_player_id;
              this.roomMyTurnPlayerName = data.my_turn_player_name;
              this.setTimerToNext();
            }
            this.processing = false;
          },
        2000
        );
      }

      const questionLog =
        {
          text: `Is it ${data.name}`,
          id: -1 * data.guessed_subject_id,
          color: this.answerValTextColors[data.answer_val-1]
        };

      this.askedQuestions.push(questionLog);
      this.guess = {};
    },
    reportTurnExpired() {
      this.$cable.perform({
        channel: "GameChannel",
        action: "process_expired_turn",
      });
    },
    turnExpiredProcessed(data){
      this.applySeries(data);
      this.gameStatus = data.game_status;
      this.expiredTurns = data.expired_turn_count;

      if(this.gameStatus == 'complete'){
        this.endGameWithoutSuccess(data.correct_subject_id);
      }
      else{
        this.message = '';
        this.headerColor = 'white';
        this.roomMyTurnPlayerId = data.my_turn_player_id;
        this.roomMyTurnPlayerName = data.my_turn_player_name;
        this.setTimerToNext();
      }
    },
    setTimerToNext() {
      if(!this.isMultiPlayer) return;

      this.turnSecondsLeft = this.secondsPerTurn;
      if(this.turnInterval) {
        clearInterval(this.turnInterval);
      }

      this.turnInterval = setInterval(() => {
        this.turnSecondsLeft -= .1;
        if (this.myTurn && this.turnSecondsLeft <= 0) {
          this.reportTurnExpired();
        }
      }, 100)
    },
    warnNotMyTurn() {
      this.message = `It's ${this.roomMyTurnPlayerName}'s Turn`;
        this.headerColor = 'red';
        setTimeout(
        () =>
          {
              this.message = '';
              this.headerColor = 'white';
          },
        2000
        );
    },
    endGameWithoutSuccess(correctSubjectId) {
      clearInterval(this.turnInterval);
      this.$refs.audioElm.pause();
      this.correctSubjectId = correctSubjectId;
      const subject = this.subjects.find(c => c.id == correctSubjectId);
      this.message = `It was ${subject.name}`;
      this.headerColor = 'red';
    },
    endGameWithSuccess(data) {
      this.$refs.audioElm.pause();
      this.message = `${data.name} is the right answer!`;
      this.headerColor = this.answerValBgColors[0];
      const winningPlayer = this.roomPlayers.find(p => p.id == data.my_turn_player_id);
      winningPlayer.score++;
      this.processing = false;
    },
    initForNewGame() {
      if(this.$refs.audioElm.paused){
        this.$refs.audioElm.currentTime = 0;
      }

      this.message = '';
      this.headerColor = 'white';
      this.askedQuestions = [];
      this.guessedSubjectIds = [];
      this.correctSubjectId = -1;
      this.expiredTurns = 0;
    }
  }
};
</script>

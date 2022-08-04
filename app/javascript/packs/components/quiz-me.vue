<template>
    <v-container>
      <audio ref="audioElm" src="/welcome/audio?id=31ljk23tjkl235l"></audio>
      <v-row>
        <v-col>
          <v-icon
            v-if="gameStatus!='mode_selection'"
            class="mb-3"
            @click="backToHome()"
          >
            mdi-home
          </v-icon>
            <div
              v-if="this.gameStatus == 'complete' && (!isMultiPlayer || isRoomHost)"
            >
              <v-btn
                color="primary"
                @click="startNewGame()"
              >
                Play Again!
              </v-btn>
            </div>
          </v-col>
      </v-row>
      <v-row>
        <v-col xs="12">

          <!-- Mode Selection div-->
          <div v-if="this.gameStatus == 'mode_selection'" class="pa-3">
            <h1>
              Welcome to Quiz Me!
            </h1>
            <v-card class="my-6 py-3">
              <v-card-title>
                Wanna give it a shot alone?
              </v-card-title>
              <v-card-text>
                <!-- <v-select
                  v-model="roomGameType"
                  :items="gameTypes"
                  label="Game Type"
                ></v-select> -->
                <v-btn
                  color="primary"
                  @click="startSoloGame()"
                >
                  Play Solo
                </v-btn>
              </v-card-text>
            </v-card>

            <v-card class="my-6 py-3">
              <v-card-title>
                Joining Friends?
              </v-card-title>
              <v-card-text>
                <span
                  v-if="roomKeyInvalid"
                  class="red--text"
                >
                  Expired or invalid room key
                </span>
                <v-text-field
                  v-model="roomKey"
                  label="Room Key"
                  hint="NOT case sensitive"
                  outlined
                  counter
                  maxlength="4"
                  >
                </v-text-field>
                <v-text-field
                  v-model="playerName"
                  hint="Doesn't have to be your real name"
                  label="Your Display Name"
                  outlined
                  counter
                  maxlength="20"
                  >
                </v-text-field>
                <v-btn
                  color="primary"
                  :disabled="!this.roomKey || !this.playerName"
                  @click="joinRoom()"
                >
                  Join Private Room
                </v-btn>
              </v-card-text>
            </v-card>

            <v-card class="my-6 py-3">
              <v-card-title>
                Ready to Start a Party?
              </v-card-title>
              <v-card-text>
                <v-btn
                  color="primary"
                  @click="setupRoom()"
                >
                  Create a Private Room
                </v-btn>
              </v-card-text>
            </v-card>
          </div>

          <!-- Room Setup card -->
          <v-card v-if="this.gameStatus == 'setup_room'" class="pa-3">
            <v-card-text>
                    <!-- <v-select
                      v-model="roomGameType"
                      :items="gameTypes"
                      label="Game Type"
                    ></v-select> -->
                    <v-text-field
                      v-model="playerName"
                      hint="Doesn't have to be your real name"
                      label="Your Display Name"
                      counter
                      maxLength="20"
                    >
                    </v-text-field>
                    <!-- <v-text-field
                      v-model="roomScoreToWin"
                      hint="3 makes sense"
                      label="Score to Win"
                    >
                    </v-text-field> -->

              <v-btn
                color="primary"
                @click="startMulti()"
              >
                Open Room
              </v-btn>
            </v-card-text>
          </v-card>

          <!-- Waiting for Players card-->
          <div v-if="this.gameStatus == 'waiting_for_players'" class="pa-3">
            <h1>Welcome to {{ this.roomHostName || 'Host' }}'s Private Room</h1>

            <h3 class="mb-6">Game Key: {{ this.roomKey }}</h3>
            <v-card class="mb-6">
              <v-card-subtitle>
                Connected Players
              </v-card-subtitle>
              <v-card-text>
                <v-list>
                  <v-list-item
                    v-for="(player) in roomPlayers"
                    :key="player.id"
                  >
                    <v-list-item-content>
                      <v-list-item-title>{{ player.name }}</v-list-item-title>
                    </v-list-item-content>
                  </v-list-item>
                </v-list>
              </v-card-text>
            </v-card>

            <v-btn
              v-if="isRoomHost"
              color="primary"
              @click="startNewGame()"
            >
              Start Game
            </v-btn>                
          </div>
          <!-- Intro Card -->
          <v-card v-if="this.gameStatus == 'intro'" class="pa-3">
            <v-card-title>
              Can you read my mind?
            </v-card-title>

            <v-card-text>
              <p>
                I'm thinking of a Bible character from the list below.
                Can you guess who it is in <strong>{{ maxQuestions }} questions or less</strong>?
                After you click "READY TO GO!" below, I'll give you 3 questions to choose from. Choose the
                question that will best help you figure out my character. Click "PAST QUESTIONS" to view
                questions you've previously asked. Click "TAKE A GUESS" to view the character list. When
                you think you've figured me out, click on the character to see if you've figured me out. Guesses count as 
                questions so use them carefully!
              </p>
              <h3>
                Character List
              </h3>
              <p>You can see this list again by clicking "Take a Guess"</p>
              <div
                v-for="character in characters"
                :key="character.name"
                >
                {{ character.name }}
              </div> 
              
              <div class="mt-6">
                <v-btn
                  color="success"
                  @click="startGame()"
                >
                  Ready to Go!
                </v-btn>
              </div>
            </v-card-text>           
          </v-card>
          
          <!-- Multiplayer Header Card-->
          <v-card
            v-if="isMultiPlayer && ['in_progress', 'complete'].indexOf(gameStatus) > -1"
            :color="myTurn ? 'green' : 'white'"
            :class="`mb-6 ${myTurn ? 'white--text' : ''}`">
            <v-card-title
            >
              {{ myTurn ? 'Your' : `${this.roomMyTurnPlayerName}'s` }} Turn
            </v-card-title>
          </v-card>

          <!-- Header/Message Card-->
          <v-card
            v-if="['intro', 'mode_selection', 'setup_room', 'waiting_for_players'].indexOf(gameStatus) === -1"
            :color="headerColor"
            :class="`game-header mb-6 ${message ? 'white--text' : ''}`"
          >
            <v-card-title>
              <span
                v-if="message"
              >
                {{ message }}
              </span>
              <span
                v-else-if="questionsLeft > 1"
                :class="questionsLeft > 4 ? 'black--text' : 'red--text'"
              >
                {{ questionsLeft }} Questions Left
              </span>
              <span
                v-else
              >
                Time to take a guess!
              </span>
            </v-card-title>
          </v-card>

          <!-- Game Div -->
          <div v-if="['intro', 'mode_selection', 'setup_room', 'waiting_for_players'].indexOf(gameStatus) === -1">

            <!-- Question Area -->
            <v-card class="mb-6 pa-5">
              <div
                v-if="gameStatus=='in_progress'"
              >
                <div
                  v-if="askedQuestions.length+1 < maxQuestions"
                >
                  <v-card-text
                    v-for="(question, index) in this.question_options"
                    :key="question.id"
                  >                
                    <v-card
                      :color="question.disabled ? 'grey' : 'indigo'"
                      :disabled="question.disabled"
                      @click="selectQuestion(index)"
                    >
                      <v-card-text
                        class="white--text"
                      >
                        {{ question.question }}?
                      </v-card-text>
                    </v-card>
                  </v-card-text>
                </div>
                <!-- <div
                  v-else
                >
                  <h2>
                    Time to take a guess below!
                  </h2>
                </div> -->
              </div>
              <div
                v-else-if="guessedCharacterIds.includes(correctCharacterId)"
              >
                <h2>
                  <span
                    v-if="askedQuestions.length / maxQuestions > .8"
                  >
                    Whew! Just made it in {{askedQuestions.length}} questions!
                  </span>
                  <span
                    v-else-if="askedQuestions.length / maxQuestions > .5"
                    >
                    {{askedQuestions.length}} questions, not bad.
                  </span>
                  <span
                    v-else
                  >
                    Unbelievable! Only {{askedQuestions.length}} questions?!?! Amazing!
                  </span>
                </h2>
              </div>
              

              <v-card-actions>
                <v-btn
                  color="orange lighten-2"
                  text
                  @click="showAskedQuestions = !showAskedQuestions"
                >
                  Past Questions
                  <v-icon>{{ showAskedQuestions ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
                </v-btn>
              </v-card-actions>

              <v-expand-transition>
                <div v-show="showAskedQuestions">
                  <v-divider></v-divider>
                  <v-card-subtitle>
                    <span class="green--text">
                      Yes
                    </span> |
                    <span class="red--text">
                      No
                    </span> |
                    <span class="amber--text">
                      Not sure
                    </span>
                </v-card-subtitle>
                <v-card-text>
                  <div
                    v-for="question in this.askedQuestions"
                    :key="question.id"
                    :class="`${question.color}--text`"
                  >
                    {{ question.text }}?
                  </div>
                </v-card-text>
                </div>
              </v-expand-transition>
              
              <v-card-actions>
                <v-btn
                  color="orange lighten-2"
                  text
                  @click="showCharacters = !showCharacters"
                >
                  Take a guess
                  <v-icon>{{ showCharacters ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
                </v-btn>
              </v-card-actions>

              <v-expand-transition>
                <div v-show="showCharacters">
                  <v-divider></v-divider>
                <v-card-text>
                  <div
                    v-for="character in characters"
                    :key="character.name"
                    class="mb-4"
                    >
                    <h3
                      v-if="correctCharacterId == character.id"
                      class="green lighten-3 white--text pa-3"
                    >
                      {{ character.name }}
                    </h3>
                    <v-btn
                      v-else
                      color="orange"
                      small
                      :disabled="guessedCharacterIds.includes(character.id) || gameStatus != 'in_progress'"
                      @click="makeGuess(character.id, character.name)"
                    >
                      {{ character.name }}
                    </v-btn>
                  </div>                  
                </v-card-text>
                </div>
              </v-expand-transition>

              <v-card-actions
                v-if="isMultiPlayer"
              >
                <v-btn
                  color="orange lighten-2"
                  text
                  @click="showPlayers = !showPlayers"
                >
                  Players
                  <v-icon>{{ showPlayers ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
                </v-btn>
              </v-card-actions>

              <v-expand-transition
                v-if="isMultiPlayer"
              >
                <div v-show="showPlayers">
                  <v-divider></v-divider>
                <v-card-text>
                  <div
                    v-for="player in roomPlayers"
                    :key="player.id"
                    :class="`mb-4 ${player.is_connected ? '' : 'grey--text'}`"
                    >
                    {{ player.name }}: {{ player.score }}
                  </div>                  
                </v-card-text>
                </div>
              </v-expand-transition>
            </v-card>
          </div>        
        </v-col>
      </v-row>
    </v-container>
</template>

<script>
import axios from "axios";

export default {
  data: () => ({
    maxQuestions: 10,
    gameTypes: ['Bible Characters'],
    roomGameType: 'Bible Characters',
    gameStatus: 'mode_selection',
    gameId: null,
    isMultiPlayer: false,
    roomKey: '',
    roomKeyInvalid: false,
    roomId: null,
    roomScoreToWin: '3',
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
    showCharacters: false,
    showPlayers: false,
    characters: [],
    guessedCharacterIds: [],
    correctCharacterId: -1,
    showAskedQuestions: false,
    askedQuestions: [],
    processing: false,
    guess: {},
    headerColor: 'white'
  }),
  created: function () {
    axios
      .get("/subjects?game_type=Bible Characters")
      .then(response => {
        this.characters = response.data.data;
      });
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
          default:
            break;
        }
      },
      disconnected() {}
    }
  },
  computed: {
    myTurn() {
      return this.roomMyTurnPlayerId == this.playerId;
    },
    questionsLeft() {
      return this.maxQuestions - this.askedQuestions.length;
    }
  },
  methods: {
    backToHome() {
      this.playerName = '';
      this.roomKey = '';
      this.gameStatus='mode_selection';
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
      this.gameStatus = "setup_room";
    },
    startSoloGame() {
      this.playerName = 'SOLO';
      this.roomScoreToWin = '0';
      this.openRoom();
    },
    startMulti() {
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
          score_to_win: this.roomScoreToWin
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
        });
    },
    refreshRoom(data) {
      if (this.gameId != data.game_id) {
        this.initForNewGame();
        this.gameId = data.game_id;
      }

      this.roomPlayers = data.players;
      this.roomHostName = data.host_player_name;
      this.roomMyTurnPlayerId = data.my_turn_player_id;
      this.roomMyTurnPlayerName = data.my_turn_player_name;
      
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
    startNewGame() {
      this.$refs.audioElm.play();
      
      this.$cable.perform({
        channel: "GameChannel",
        action: "start_new_game"
      });
    },
    startGame() {
      axios
        .post("/pick_subject/games", 
        {
          game_type: "Bible Characters",
          room_id: this.roomId,
          player_id: this.playerId
        })
        .then(response => {
          const data = response.data.data;
          this.gameId = data.game_id;

          this.question_options = data.next_question_options;
          this.gameStatus = data.game_status;
        })
        .catch(e => {
          console.log(e);
        });
    },
    selectQuestion(index) {
      if(!this.myTurn){
        this.warnNotMyTurn();
        return;
      }

      if(this.processing) return;
      this.processing = true;
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
              this.correctCharacterId = data.correct_subject_id;
              const character = this.characters.find(c => c.id == data.correct_subject_id);
              this.message = `It was ${character.name}`;
              this.headerColor = this.answerValBgColors[1];
            }
            else{
              this.message = '';
              this.headerColor = 'white';
              this.question_options = data.next_question_options;
              this.roomMyTurnPlayerId = data.my_turn_player_id;
              this.roomMyTurnPlayerName = data.my_turn_player_name;
            }
            this.processing = false;
          },
        1000
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
        this.processing = true;
        this.guessedCharacterIds.push(subjectId);

        this.$cable.perform({
          channel: "GameChannel",
          action: "process_guess",
          data: {
            subject_id: subjectId
          },
        });
    },
    guessProcessed(data) {
      this.gameStatus = data.game_status;
      this.correctCharacterId = data.correct_subject_id

      if(data.answer_val == 1){
        this.message = `${data.name} is the right answer!`
        this.headerColor = this.answerValBgColors[0];
        this.processing = false;
      }
      else if(data.answer_val == 2){
        this.message = `Not ${data.name}`;
        this.headerColor = this.answerValBgColors[1];
        setTimeout(
        () =>
          {
            if(this.gameStatus == 'complete'){
              this.correctCharacterId = data.correct_subject_id;
              const character = this.characters.find(c => c.id == data.correct_subject_id);
              this.message = `It was ${character.name}`;
              this.headerColor = 'red';
            }
            else{
              this.message = '';
              this.headerColor = 'white';
              this.roomMyTurnPlayerId = data.my_turn_player_id;
              this.roomMyTurnPlayerName = data.my_turn_player_name;
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
    initForNewGame() {
      this.message = '';
      this.headerColor = 'white';
      this.askedQuestions = [];
      this.guessedCharacterIds = [];
      this.correctCharacterId = -1;
    }
  }
};
  
</script>
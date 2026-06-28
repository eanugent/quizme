<template>
  <div class="hv">
    <!-- Header: series status + room key -->
    <div class="hv-header">
      <div class="hv-series">
        <span class="hv-eyebrow">{{ seriesLabel }}</span>
        <h1 class="hv-title">{{ headline }}</h1>
        <div class="hv-series-meta">{{ seriesMeta }}</div>
      </div>
      <div class="hv-roomkey">
        <small>Room Key</small>
        <strong>{{ roomKey }}</strong>
      </div>
    </div>

    <div class="hv-body">
      <!-- Live game panel -->
      <div class="hv-stage">
        <div v-if="gameStatus === 'in_progress'" class="hv-turn">
          <div class="hv-timer">
            <svg viewBox="0 0 120 120" width="120" height="120">
              <circle
                cx="60" cy="60" r="52"
                fill="none"
                stroke="rgba(255,255,255,0.10)"
                stroke-width="8"
              ></circle>
              <circle
                cx="60" cy="60" r="52"
                fill="none"
                stroke="url(#qm-timer-grad)"
                stroke-width="8"
                stroke-linecap="round"
                transform="rotate(-90 60 60)"
                :stroke-dasharray="circumference"
                :stroke-dashoffset="dashOffset"
              ></circle>
            </svg>
            <span class="hv-timer-num">{{ secondsLeftDisplay }}</span>
          </div>
          <div class="hv-turn-name">
            <small>Now playing</small>
            <strong>{{ myTurnPlayerName || '—' }}</strong>
          </div>
          <div :class="['hv-banner', bannerClass]" v-if="message">{{ message }}</div>
          <div class="hv-qleft" v-else>
            <span class="hv-qleft-num">{{ questionsLeft }}</span>
            <span>{{ questionsLeft === 1 ? 'guess left' : 'questions left' }}</span>
          </div>
        </div>

        <div v-else class="hv-intermission">
          <div class="hv-intermission-icon">{{ '\u{1F3AC}' }}</div>
          <h2>{{ intermissionTitle }}</h2>
          <p>{{ intermissionSub }}</p>
          <button
            v-if="seriesStatus !== 'complete'"
            class="hv-start-btn"
            @click="$emit('start-next-game')"
          >
            {{ startButtonLabel }}
          </button>
        </div>

        <!-- Recent answers ticker -->
        <div v-if="askedQuestions.length" class="hv-log">
          <div
            v-for="q in recentAsked"
            :key="q.id"
            :class="['hv-log-item', `hv-log-${logVariant(q.color)}`]"
          >
            <span class="hv-log-dot"></span>
            <span class="hv-log-text">{{ q.text }}?</span>
          </div>
        </div>
      </div>

      <!-- Scoreboard -->
      <div class="hv-scoreboard">
        <div class="hv-scoreboard-head">
          <span>Series Standings</span>
          <span class="hv-target">first to {{ scoreToWin }}</span>
        </div>
        <div
          v-for="(p, i) in ranked"
          :key="p.id"
          :class="['hv-score-row', p.id === myTurnPlayerId && gameStatus === 'in_progress' ? 'hv-active' : '', p.is_connected ? '' : 'hv-offline']"
        >
          <span class="hv-rank">{{ i + 1 }}</span>
          <span class="hv-avatar">{{ initial(p.name) }}</span>
          <div class="hv-score-main">
            <div class="hv-score-name">
              {{ p.name }}
              <span v-if="!p.is_connected" class="hv-offline-tag">offline</span>
            </div>
            <div class="hv-pips">
              <span
                v-for="n in scoreToWin"
                :key="n"
                :class="['hv-pip', n <= p.score ? 'hv-pip-on' : '']"
              ></span>
            </div>
          </div>
          <span class="hv-score-num">{{ p.score }}</span>
        </div>
        <div v-if="!ranked.length" class="hv-empty">Waiting for players to join&hellip;</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'HostView',
  props: {
    roomKey: { type: String, default: '' },
    players: { type: Array, default: () => [] },
    gameStatus: { type: String, default: '' },
    seriesStatus: { type: String, default: 'in_progress' },
    gamesCompleted: { type: Number, default: 0 },
    totalGames: { type: Number, default: 1 },
    scoreToWin: { type: Number, default: 1 },
    myTurnPlayerId: { type: [String, Number], default: null },
    myTurnPlayerName: { type: String, default: '' },
    turnSecondsLeft: { type: Number, default: 0 },
    secondsPerTurn: { type: Number, default: 60 },
    questionsLeft: { type: Number, default: 0 },
    askedQuestions: { type: Array, default: () => [] },
    message: { type: String, default: '' },
    bannerClass: { type: String, default: '' }
  },
  computed: {
    ranked() {
      return [...this.players]
        .map(p => ({ ...p, score: Number(p.score) || 0 }))
        .sort((a, b) => b.score - a.score);
    },
    currentGameNumber() {
      return this.gameStatus === 'in_progress' ? this.gamesCompleted + 1 : this.gamesCompleted;
    },
    isSuddenDeath() {
      return this.currentGameNumber > this.totalGames || this.gamesCompleted >= this.totalGames;
    },
    seriesLabel() {
      if (this.totalGames <= 1) return 'Single Game';
      return `Best of ${this.totalGames}`;
    },
    headline() {
      if (this.gameStatus === 'in_progress') {
        return this.isSuddenDeath && this.totalGames > 1
          ? 'Sudden Death!'
          : `Game ${this.currentGameNumber}`;
      }
      return 'Quiz Me';
    },
    seriesMeta() {
      if (this.totalGames <= 1) return 'Winner takes the round';
      return `${this.gamesCompleted} of ${this.totalGames} games played · first to ${this.scoreToWin} wins`;
    },
    intermissionTitle() {
      if (this.gamesCompleted === 0) return 'Get Ready!';
      return this.isSuddenDeath ? "It's a tie!" : 'Round Over';
    },
    intermissionSub() {
      if (this.gamesCompleted === 0) return 'Players, look at your devices.';
      return this.isSuddenDeath
        ? 'A sudden-death game will decide it.'
        : 'Next game coming up.';
    },
    startButtonLabel() {
      if (this.gamesCompleted === 0) return `Start Game 1 of ${this.totalGames}`;
      if (this.isSuddenDeath && this.totalGames > 1) return 'Start Sudden-Death Game';
      return `Start Game ${this.gamesCompleted + 1} of ${this.totalGames}`;
    },
    recentAsked() {
      return this.askedQuestions.slice(-4);
    },
    circumference() {
      return 2 * Math.PI * 52;
    },
    dashOffset() {
      const pct = Math.max(0, Math.min(1, this.turnSecondsLeft / (this.secondsPerTurn || 1)));
      return this.circumference * (1 - pct);
    },
    secondsLeftDisplay() {
      return Math.max(0, Math.ceil(this.turnSecondsLeft));
    }
  },
  methods: {
    initial(name) {
      return (name || '?').trim().charAt(0).toUpperCase();
    },
    logVariant(color) {
      if (color === 'green') return 'yes';
      if (color === 'red') return 'no';
      return 'maybe';
    }
  }
};
</script>


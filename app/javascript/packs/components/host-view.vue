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

<style scoped>
.hv {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  color: var(--qm-text);
}
.hv-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 24px;
  flex-wrap: wrap;
  margin-bottom: 22px;
}
.hv-eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.28em;
  font-size: 0.78rem;
  color: var(--qm-gold-soft);
}
.hv-title {
  font-family: 'Fraunces', serif;
  font-weight: 700;
  font-size: clamp(2rem, 5vw, 3.4rem);
  line-height: 1.05;
  margin: 4px 0;
}
.hv-series-meta { color: var(--qm-text-dim); font-size: 1rem; }
.hv-roomkey {
  text-align: center;
  background: var(--qm-glass-strong);
  border: 1px solid var(--qm-border-strong);
  border-radius: 16px;
  padding: 10px 22px;
  box-shadow: var(--qm-shadow);
}
.hv-roomkey small {
  display: block;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  font-size: 0.66rem;
  color: var(--qm-text-muted);
}
.hv-roomkey strong {
  font-family: 'Fraunces', serif;
  font-size: clamp(2rem, 5vw, 3rem);
  letter-spacing: 0.12em;
  color: var(--qm-gold);
}

.hv-body {
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 22px;
}
@media (max-width: 900px) {
  .hv-body { grid-template-columns: 1fr; }
}

.hv-stage {
  background: var(--qm-glass);
  border: 1px solid var(--qm-border);
  border-radius: 22px;
  padding: 28px;
  box-shadow: var(--qm-shadow);
  min-height: 320px;
  display: flex;
  flex-direction: column;
}
.hv-turn { display: flex; flex-direction: column; align-items: center; gap: 14px; flex: 1; justify-content: center; }
.hv-timer { position: relative; width: 120px; height: 120px; }
.hv-timer svg { display: block; width: 120px; height: 120px; }
.hv-timer svg circle { transition: stroke-dashoffset 0.1s linear; }
.hv-timer-num {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  font-family: 'Fraunces', serif;
  font-weight: 700;
  font-size: 2.4rem;
  color: var(--qm-text);
}
.hv-turn-name { text-align: center; }
.hv-turn-name small {
  display: block;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  font-size: 0.72rem;
  color: var(--qm-text-muted);
}
.hv-turn-name strong { font-size: clamp(1.6rem, 4vw, 2.6rem); font-family: 'Fraunces', serif; }
.hv-qleft { display: flex; align-items: baseline; gap: 10px; color: var(--qm-text-dim); }
.hv-qleft-num { font-size: 2rem; font-weight: 700; color: var(--qm-gold); }
.hv-banner {
  padding: 10px 22px;
  border-radius: 999px;
  font-weight: 700;
  font-size: 1.3rem;
  background: var(--qm-glass-strong);
  border: 1px solid var(--qm-border-strong);
}
.hv-banner.qm-msg-yes { color: #34d399; border-color: rgba(52,211,153,0.4); }
.hv-banner.qm-msg-no, .hv-banner.qm-msg-warn { color: #f87171; border-color: rgba(248,113,113,0.4); }
.hv-banner.qm-msg-maybe { color: #fbbf24; border-color: rgba(251,191,36,0.4); }

.hv-intermission { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; text-align: center; }
.hv-intermission-icon { font-size: 3.4rem; }
.hv-intermission h2 { font-family: 'Fraunces', serif; font-size: 2rem; }
.hv-intermission p { color: var(--qm-text-dim); }
.hv-start-btn {
  margin-top: 10px;
  padding: 14px 30px;
  border-radius: 999px;
  font-weight: 700;
  font-size: 1.1rem;
  color: #1a1430;
  background: linear-gradient(135deg, var(--qm-gold-soft), var(--qm-gold));
  box-shadow: 0 12px 30px -8px rgba(250,204,21,0.6);
  cursor: pointer;
  transition: transform 0.15s ease;
}
.hv-start-btn:hover { transform: translateY(-2px); }

.hv-log { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 18px; }
.hv-log-item {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  border-radius: 999px;
  background: rgba(255,255,255,0.04);
  border: 1px solid var(--qm-border);
  font-size: 0.85rem;
  color: var(--qm-text-dim);
  max-width: 100%;
}
.hv-log-text { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 240px; }
.hv-log-dot { width: 9px; height: 9px; border-radius: 50%; flex: none; }
.hv-log-yes .hv-log-dot { background: #34d399; }
.hv-log-no .hv-log-dot { background: #f87171; }
.hv-log-maybe .hv-log-dot { background: #fbbf24; }

/* Scoreboard */
.hv-scoreboard {
  background: var(--qm-glass);
  border: 1px solid var(--qm-border);
  border-radius: 22px;
  padding: 22px;
  box-shadow: var(--qm-shadow);
}
.hv-scoreboard-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 16px;
}
.hv-scoreboard-head > span:first-child {
  text-transform: uppercase;
  letter-spacing: 0.18em;
  font-size: 0.82rem;
  color: var(--qm-text-muted);
}
.hv-target { color: var(--qm-gold); font-weight: 600; font-size: 0.85rem; }
.hv-score-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: 14px;
  margin-bottom: 8px;
  background: rgba(255,255,255,0.02);
  border: 1px solid transparent;
  transition: all 0.2s ease;
}
.hv-active {
  border-color: var(--qm-gold);
  background: rgba(250,204,21,0.08);
  box-shadow: 0 0 0 1px rgba(250,204,21,0.2);
}
.hv-offline { opacity: 0.5; }
.hv-rank { width: 20px; text-align: center; color: var(--qm-text-muted); font-weight: 700; }
.hv-avatar {
  width: 40px; height: 40px; border-radius: 50%;
  display: grid; place-items: center;
  font-weight: 700;
  color: #1a1430;
  background: linear-gradient(135deg, var(--qm-violet-2), var(--qm-pink));
  flex: none;
}
.hv-score-main { flex: 1; min-width: 0; }
.hv-score-name { font-weight: 600; display: flex; align-items: center; gap: 8px; }
.hv-offline-tag { font-size: 0.66rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--qm-text-muted); }
.hv-pips { display: flex; gap: 5px; margin-top: 6px; flex-wrap: wrap; }
.hv-pip { width: 14px; height: 8px; border-radius: 3px; background: rgba(255,255,255,0.12); transition: background 0.3s ease; }
.hv-pip-on { background: linear-gradient(135deg, var(--qm-gold-soft), var(--qm-gold)); }
.hv-score-num {
  font-family: 'Fraunces', serif;
  font-weight: 700;
  font-size: 1.8rem;
  color: var(--qm-gold);
  min-width: 28px;
  text-align: right;
}
.hv-empty { color: var(--qm-text-muted); text-align: center; padding: 20px 0; }
</style>

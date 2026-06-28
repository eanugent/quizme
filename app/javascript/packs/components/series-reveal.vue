<template>
  <div :class="['sr-overlay', grand ? 'sr-grand' : '']">
    <!-- Confetti -->
    <div v-if="phase === 'reveal'" class="sr-confetti" aria-hidden="true">
      <span
        v-for="piece in confetti"
        :key="piece.id"
        class="sr-confetti-piece"
        :style="piece.style"
      ></span>
    </div>

    <!-- Suspense build-up -->
    <transition name="sr-fade">
      <div v-if="phase === 'suspense'" class="sr-suspense">
        <div class="sr-drumroll">
          <span></span><span></span><span></span>
        </div>
        <h2 class="sr-suspense-text">And the series winner is&hellip;</h2>
      </div>
    </transition>

    <!-- The reveal -->
    <transition name="sr-pop">
      <div v-if="phase === 'reveal'" class="sr-reveal">
        <div class="sr-crown">{{ '\u{1F451}' }}</div>
        <div class="sr-winner-label">Series Champion</div>
        <h1 class="sr-winner-name">{{ winnerName }}</h1>
        <div class="sr-winner-sub">
          {{ winnerScore }} {{ winnerScore === 1 ? 'game' : 'games' }} won
        </div>

        <!-- Podium -->
        <div class="sr-podium">
          <div
            v-for="(p, i) in podium"
            :key="p.id"
            :class="['sr-pillar', `sr-rank-${p.rank}`, p.id === winnerPlayerId ? 'sr-pillar-win' : '']"
            :style="{ animationDelay: (0.15 * i) + 's' }"
          >
            <div class="sr-pillar-avatar">{{ initial(p.name) }}</div>
            <div class="sr-pillar-name">{{ p.name }}</div>
            <div class="sr-pillar-block">
              <span class="sr-pillar-medal">{{ medal(p.rank) }}</span>
              <span class="sr-pillar-score">{{ p.score }}</span>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>
const CONFETTI_COLORS = ['#facc15', '#ec4899', '#a855f7', '#34d399', '#60a5fa', '#fde68a'];

export default {
  name: 'SeriesReveal',
  props: {
    players: { type: Array, default: () => [] },
    winnerPlayerId: { type: [String, Number], default: null },
    grand: { type: Boolean, default: false }
  },
  data: () => ({
    phase: 'suspense',
    confetti: [],
    timers: []
  }),
  computed: {
    ranked() {
      return [...this.players]
        .map(p => ({ id: p.id, name: p.name, score: Number(p.score) || 0 }))
        .sort((a, b) => b.score - a.score);
    },
    podium() {
      // Center the winner: order as 2nd, 1st, 3rd for a classic podium look.
      const top = this.ranked.slice(0, 3).map((p, idx) => ({ ...p, rank: idx + 1 }));
      const order = [top[1], top[0], top[2]].filter(Boolean);
      return order;
    },
    winner() {
      return this.ranked.find(p => p.id === this.winnerPlayerId) || this.ranked[0] || {};
    },
    winnerName() {
      return this.winner.name || 'Nobody';
    },
    winnerScore() {
      return this.winner.score || 0;
    }
  },
  mounted() {
    this.buildConfetti();
    this.timers.push(setTimeout(() => { this.phase = 'reveal'; this.boom(); }, 2600));
  },
  beforeDestroy() {
    this.timers.forEach(clearTimeout);
  },
  methods: {
    initial(name) {
      return (name || '?').trim().charAt(0).toUpperCase();
    },
    medal(rank) {
      return { 1: '\u{1F947}', 2: '\u{1F948}', 3: '\u{1F949}' }[rank] || '';
    },
    buildConfetti() {
      const count = this.grand ? 140 : 80;
      this.confetti = Array.from({ length: count }, (_, i) => {
        const left = Math.random() * 100;
        const delay = Math.random() * 2.5;
        const duration = 2.8 + Math.random() * 2.4;
        const color = CONFETTI_COLORS[i % CONFETTI_COLORS.length];
        const size = 6 + Math.random() * 8;
        const rotate = Math.random() * 360;
        return {
          id: i,
          style: {
            left: left + '%',
            background: color,
            width: size + 'px',
            height: size * 1.4 + 'px',
            animationDelay: delay + 's',
            animationDuration: duration + 's',
            transform: `rotate(${rotate}deg)`
          }
        };
      });
    },
    boom() {
      // Re-seed confetti on reveal so it bursts from the top fresh.
      this.buildConfetti();
    }
  }
};
</script>


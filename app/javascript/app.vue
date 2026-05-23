<template>
  <v-app id="app" class="qm-app">
    <div class="qm-bg" aria-hidden="true"></div>
    <div class="qm-bg-stars" aria-hidden="true"></div>

    <v-app-bar app flat dark class="qm-appbar" height="68">
      <v-toolbar-title class="qm-brand">
        <span class="qm-brand-mark">Q</span>
        <span>Quiz<span class="qm-brand-accent">Me</span></span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <span class="qm-brand-tag">Read my mind&hellip;</span>
    </v-app-bar>

    <v-main class="qm-main">
      <v-container fluid class="qm-shell">
        <quiz-me></quiz-me>
      </v-container>
    </v-main>

    <!-- Shared SVG defs for the timer ring gradient -->
    <svg width="0" height="0" style="position:absolute" aria-hidden="true">
      <defs>
        <linearGradient id="qm-timer-grad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#facc15"/>
          <stop offset="100%" stop-color="#ec4899"/>
        </linearGradient>
      </defs>
    </svg>
  </v-app>
</template>

<script>
import quizMe from './packs/components/quiz-me.vue';

export default {
  components: { quizMe }
}
</script>

<style scoped>
.qm-brand-tag {
  font-family: 'Inter', sans-serif;
  font-size: 0.78rem;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: rgba(244, 241, 255, 0.55);
  font-style: italic;
}
@media (max-width: 480px) {
  .qm-brand-tag { display: none; }
}
</style>

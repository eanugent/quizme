<template>
  <v-app id="app">
    <v-app-bar app dark class="indigo">
      <v-toolbar-title class="headline text-uppercase">
        <span>Quiz Me &nbsp;</span>
      </v-toolbar-title>
    </v-app-bar>
    <v-main>
      <v-container fluid>
        <quiz-me>
        </quiz-me>
      </v-container>
    </v-main>
  </v-app>
</template>
  
<script> 
import quizMe from './packs/components/quiz-me.vue';

export default {
  components: { quizMe }
}

</script>

<style scoped>

</style>

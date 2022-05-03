<template>
  <v-app id="app">
    <!-- <v-navigation-drawer app></v-navigation-drawer> -->
    <v-app-bar app dark class="indigo">
      <v-toolbar-title class="headline text-uppercase">
        <span>Quiz Me &nbsp;</span>          
      </v-toolbar-title>
    </v-app-bar>
    <v-main>
      <guess-subject>
      </guess-subject>
    </v-main>
  </v-app>
</template>
  
<script> 
import guessSubject from './packs/components/guess-subject.vue';

export default {
  components: { guessSubject }
}

</script>

<style scoped>

</style>

<template>
  <v-app id="app">
    <!-- https://vuetifyjs.com/en/components/navigation-drawers/#usage
      <v-navigation-drawer permanent>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title class="text-h6">
            Application
          </v-list-item-title>
          <v-list-item-subtitle>
            subtext
          </v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>

      <v-divider></v-divider>

      <v-list
        dense
        nav
      >
        <v-list-item          
          link
        >
          <v-list-item-icon>
            <v-icon></v-icon>
          </v-list-item-icon>

          <v-list-item-content>
            <v-list-item-title>Read My Mind</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
        <v-list-item          
          link
        >
          <v-list-item-icon>
            <v-icon></v-icon>
          </v-list-item-icon>

          <v-list-item-content>
            <v-list-item-title>Read Your Mind</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-navigation-drawer> -->
    <v-app-bar app dark class="indigo">
      <v-toolbar-title class="headline text-uppercase">
        <span>Quiz Me &nbsp;</span>          
      </v-toolbar-title>
    </v-app-bar>
    <v-main>
      <v-container fluid>
        <pick-subject>
        </pick-subject>
      </v-container>
    </v-main>
  </v-app>
</template>
  
<script> 
// import guessSubject from './packs/components/guess-subject.vue';
import pickSubject from './packs/components/pick-subject.vue';

export default {
  components: { pickSubject }
}

</script>

<style scoped>

</style>

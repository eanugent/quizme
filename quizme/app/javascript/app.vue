<template>
  <div id="app">
    <v-app>
    <guess-subject>
    </guess-subject>
    </v-app>
  </div>
</template>
  
<script> 
import guessSubject from './packs/components/guess-subject.vue';

export default {
  components: { guessSubject },
  data: function () {
    return {
      message: "Hello Vue!"
    }
  }
}

</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>

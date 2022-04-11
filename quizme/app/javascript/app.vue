<template>
  <div id="app">
    <p>{{ message }}</p>
    <v-btn
  elevation="2"
> Click Me
</v-btn>
  </div>
</template>

<script> 

export default {
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

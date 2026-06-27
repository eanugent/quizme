<template>
  <v-main>
    <v-container class="fill-height" fluid>
      <v-row align="center" justify="center">
        <v-col cols="12" sm="8" md="4">
          <v-card class="pa-6" color="#15132e" flat>
            <v-card-title class="justify-center text-h5 mb-2">Quiz Me Admin</v-card-title>
            <v-card-subtitle class="text-center mb-4">Sign in to manage content</v-card-subtitle>

            <v-alert v-if="error" type="error" dense text class="mb-4">{{ error }}</v-alert>

            <v-form @submit.prevent="login">
              <v-text-field
                v-model="username"
                label="Username"
                autocomplete="username"
                outlined
                dense
                :disabled="loading"
              ></v-text-field>
              <v-text-field
                v-model="password"
                label="Password"
                type="password"
                autocomplete="current-password"
                outlined
                dense
                :disabled="loading"
              ></v-text-field>
              <v-btn
                type="submit"
                color="primary"
                block
                large
                :loading="loading"
              >
                Sign In
              </v-btn>
            </v-form>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-main>
</template>

<script>
import adminApi from '../../admin-api'

export default {
  data() {
    return {
      username: '',
      password: '',
      error: '',
      loading: false
    }
  },
  methods: {
    async login() {
      this.error = ''
      this.loading = true

      try {
        await adminApi.post('/admin/session', {
          username: this.username,
          password: this.password
        })
        this.$router.push('/admin/characters')
      } catch (error) {
        if (error.response?.status === 429) {
          this.error = error.response.data.error
        } else {
          this.error = 'Invalid username or password'
        }
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<template>
  <div>
    <v-app-bar app flat dark color="#15132e" height="64">
      <v-toolbar-title>Quiz Me Admin</v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn text @click="logout">
        <v-icon left>mdi-logout</v-icon>
        Sign Out
      </v-btn>
    </v-app-bar>

    <v-navigation-drawer app permanent dark color="#12102a" width="240">
      <v-list nav dense>
        <v-list-item-group :value="0" color="primary">
          <v-list-item :to="{ name: 'characters' }" exact>
            <v-list-item-icon>
              <v-icon>mdi-account-group</v-icon>
            </v-list-item-icon>
            <v-list-item-title>Manage Characters</v-list-item-title>
          </v-list-item>
        </v-list-item-group>
      </v-list>
    </v-navigation-drawer>

    <v-main>
      <v-container fluid class="pa-6">
        <router-view></router-view>
      </v-container>
    </v-main>
  </div>
</template>

<script>
import adminApi from '../../admin-api'

export default {
  methods: {
    async logout() {
      await adminApi.delete('/admin/session')
      this.$router.push('/admin/login')
    }
  }
}
</script>

<template>
  <div>
    <div class="d-flex flex-wrap align-center mb-6" style="gap: 16px;">
      <h1 class="text-h5 mr-4 mb-0">Manage Characters</h1>
      <v-spacer class="d-none d-sm-flex"></v-spacer>

      <v-select
        v-model="gameType"
        :items="gameTypes"
        label="Game Type"
        outlined
        dense
        hide-details
        style="max-width: 220px;"
        :disabled="loading"
        @change="onGameTypeChange"
      ></v-select>

      <v-select
        v-model="selectedSubjectId"
        :items="subjectOptions"
        item-text="name"
        item-value="id"
        label="Character"
        outlined
        dense
        hide-details
        style="max-width: 280px;"
        :disabled="loading || !gameType"
        @change="loadSubject"
      ></v-select>

      <v-btn color="primary" depressed :disabled="!gameType" @click="openNewCharacter">
        <v-icon left>mdi-plus</v-icon>
        Add Character
      </v-btn>
    </div>

    <v-alert v-if="error" type="error" dense text class="mb-4">{{ error }}</v-alert>

    <v-card v-if="currentSubject" color="#15132e" flat class="pa-4">
      <div class="d-flex align-center mb-4">
        <v-text-field
          v-model="currentSubject.name"
          label="Character Name"
          outlined
          dense
          hide-details
          style="max-width: 320px;"
          :disabled="saving"
        ></v-text-field>
        <v-spacer></v-spacer>
        <span v-if="saveStatus" class="text-caption" :class="saveStatusClass">{{ saveStatus }}</span>
      </div>

      <v-divider class="mb-4"></v-divider>

      <div
        v-for="answer in currentSubject.answers"
        :key="answer.question_id"
        class="answer-row d-flex flex-wrap align-center py-3"
      >
        <div class="answer-question flex-grow-1 pr-4">{{ answer.question }}</div>
        <v-btn-toggle
          :value="answer.answer_val"
          mandatory
          dense
          class="answer-toggle"
          :disabled="saving"
          @input="val => setAnswer(answer, val)"
        >
          <v-btn :value="1" small class="yes-btn">Yes</v-btn>
          <v-btn :value="2" small class="no-btn">No</v-btn>
          <v-btn :value="3" small class="unsure-btn">Not sure</v-btn>
        </v-btn-toggle>
      </div>
    </v-card>

    <v-card v-else-if="!loading && gameType" color="#15132e" flat class="pa-8 text-center">
      <v-icon size="48" color="grey">mdi-account-question</v-icon>
      <p class="mt-4 mb-0 grey--text">Select a character or add a new one to edit answers.</p>
    </v-card>

    <v-dialog v-model="newCharacterDialog" max-width="720" scrollable>
      <v-card color="#15132e">
        <v-card-title>Add Character</v-card-title>
        <v-card-text>
          <v-text-field
            v-model="newCharacter.name"
            label="Character Name"
            outlined
            dense
            class="mb-4"
            :error-messages="newCharacterError"
          ></v-text-field>

          <div
            v-for="answer in newCharacter.answers"
            :key="answer.question_id"
            class="answer-row d-flex flex-wrap align-center py-2"
          >
            <div class="answer-question flex-grow-1 pr-4">{{ answer.question }}</div>
            <v-btn-toggle
              v-model="answer.answer_val"
              mandatory
              dense
              class="answer-toggle"
            >
              <v-btn :value="1" small class="yes-btn">Yes</v-btn>
              <v-btn :value="2" small class="no-btn">No</v-btn>
              <v-btn :value="3" small class="unsure-btn">Not sure</v-btn>
            </v-btn-toggle>
          </div>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn text @click="newCharacterDialog = false">Cancel</v-btn>
          <v-btn color="primary" depressed :loading="creating" @click="createCharacter">Create</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
import adminApi from '../../admin-api'

export default {
  data() {
    return {
      gameTypes: [],
      gameType: null,
      subjects: [],
      selectedSubjectId: null,
      currentSubject: null,
      loading: false,
      saving: false,
      creating: false,
      error: '',
      saveStatus: '',
      saveStatusClass: '',
      saveTimer: null,
      newCharacterDialog: false,
      newCharacterError: '',
      newCharacter: { name: '', answers: [] }
    }
  },
  computed: {
    subjectOptions() {
      return this.subjects
    }
  },
  watch: {
    'currentSubject.name'() {
      this.scheduleSave()
    }
  },
  async created() {
    await this.loadGameTypes()
  },
  methods: {
    async loadGameTypes() {
      this.loading = true
      this.error = ''

      try {
        const response = await adminApi.get('/admin/game_types')
        this.gameTypes = response.data.data
        if (this.gameTypes.length > 0) {
          this.gameType = this.gameTypes[0]
          await this.loadSubjects()
        }
      } catch (_error) {
        this.error = 'Failed to load game types'
      } finally {
        this.loading = false
      }
    },
    async onGameTypeChange() {
      this.selectedSubjectId = null
      this.currentSubject = null
      await this.loadSubjects()
    },
    async loadSubjects() {
      if (!this.gameType) return

      this.loading = true
      this.error = ''

      try {
        const response = await adminApi.get('/admin/subjects', {
          params: { game_type: this.gameType }
        })
        this.subjects = response.data.data
      } catch (_error) {
        this.error = 'Failed to load characters'
      } finally {
        this.loading = false
      }
    },
    async loadSubject() {
      if (!this.selectedSubjectId) {
        this.currentSubject = null
        return
      }

      this.loading = true
      this.error = ''
      this.saveStatus = ''

      try {
        const response = await adminApi.get(`/admin/subjects/${this.selectedSubjectId}`, {
          params: { game_type: this.gameType }
        })
        this.currentSubject = response.data.data
      } catch (_error) {
        this.error = 'Failed to load character'
      } finally {
        this.loading = false
      }
    },
    setAnswer(answer, value) {
      answer.answer_val = value
      this.scheduleSave()
    },
    scheduleSave() {
      if (!this.currentSubject?.id) return

      clearTimeout(this.saveTimer)
      this.saveStatus = 'Saving...'
      this.saveStatusClass = 'grey--text'

      this.saveTimer = setTimeout(() => {
        this.saveSubject()
      }, 600)
    },
    async saveSubject() {
      if (!this.currentSubject?.id) return

      this.saving = true
      this.error = ''

      try {
        const response = await adminApi.patch(`/admin/subjects/${this.currentSubject.id}`, {
          game_type: this.gameType,
          name: this.currentSubject.name,
          answers: this.currentSubject.answers.map(a => ({
            question_id: a.question_id,
            answer_val: a.answer_val
          }))
        })
        this.currentSubject = response.data.data
        this.subjects = this.subjects
          .map(s => (s.id === this.currentSubject.id ? { ...s, name: this.currentSubject.name } : s))
          .sort((a, b) => a.name.localeCompare(b.name))
        this.saveStatus = 'Saved'
        this.saveStatusClass = 'success--text'
      } catch (_error) {
        this.saveStatus = 'Save failed'
        this.saveStatusClass = 'error--text'
        this.error = 'Failed to save changes'
      } finally {
        this.saving = false
      }
    },
    async openNewCharacter() {
      this.newCharacterError = ''
      this.newCharacter = { name: '', answers: [] }
      this.newCharacterDialog = true

      try {
        const response = await adminApi.get('/admin/subjects/new_template', {
          params: { game_type: this.gameType }
        })
        this.newCharacter.answers = response.data.data.answers
      } catch (_error) {
        this.error = 'Failed to load questions'
        this.newCharacterDialog = false
      }
    },
    async createCharacter() {
      if (!this.newCharacter.name.trim()) {
        this.newCharacterError = 'Name is required'
        return
      }

      this.creating = true
      this.newCharacterError = ''
      this.error = ''

      try {
        const response = await adminApi.post('/admin/subjects', {
          game_type: this.gameType,
          name: this.newCharacter.name.trim(),
          answers: this.newCharacter.answers.map(a => ({
            question_id: a.question_id,
            answer_val: a.answer_val
          }))
        })
        const created = response.data.data
        this.subjects.push({ id: created.id, name: created.name, game_type: created.game_type })
        this.subjects.sort((a, b) => a.name.localeCompare(b.name))
        this.selectedSubjectId = created.id
        this.currentSubject = created
        this.newCharacterDialog = false
      } catch (error) {
        this.newCharacterError = error.response?.data?.error || 'Failed to create character'
      } finally {
        this.creating = false
      }
    }
  }
}
</script>

<style scoped>
.answer-row {
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}
.answer-row:last-child {
  border-bottom: none;
}
.answer-question {
  min-width: 200px;
  line-height: 1.4;
}
.answer-toggle .yes-btn.v-btn--active {
  background-color: #34d399 !important;
  color: #0b0a1f !important;
}
.answer-toggle .no-btn.v-btn--active {
  background-color: #f87171 !important;
  color: #0b0a1f !important;
}
.answer-toggle .unsure-btn.v-btn--active {
  background-color: #fbbf24 !important;
  color: #0b0a1f !important;
}
</style>

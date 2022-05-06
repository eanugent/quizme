<template>
  <div>
    <v-layout>
    <v-flex xs12 sm6 offset-sm3>
      <v-card class="my-6">
        <v-card-title>
          Can I read your mind?
        </v-card-title>
      </v-card>

      <v-card v-if="this.gameStatus == 'choosing_character'" class="mb-6">
        <v-card-title>
          Choose a character from the list below
        </v-card-title>
        <v-card-text>
          <ul class="mb-6">
            <li
              v-for="character in characters"
              :key="character.name"
              >
              {{ character.name }}
            </li>
          </ul>
          <v-btn @click="startGame()">
            Ready to Go!
          </v-btn>
        </v-card-text>
      </v-card>
       
      <v-card  v-if="this.gameStatus == 'in_progress'" class="mb-6 pa-5">
        <v-card-title primary-title>
          {{ question ? `${question.question}?` : ''}}
        </v-card-title>
        <v-card-actions>
          <!-- <v-container fluid px-0>
            <v-radio-group v-model="answerVal">
              <v-radio
                v-for="(answer, index) in answerVals"
                :key="index+1"
                :label="answer"
                :value="index+1"
                @click="processAnswer()"
              ></v-radio>
            </v-radio-group>
          </v-container> -->
          <v-btn flat color="orange" @click="processAnswer(1)">Yes</v-btn>
          <v-btn flat color="orange" @click="processAnswer(2)">No</v-btn>
          <v-btn flat color="orange" @click="processAnswer(3)">Not Sure</v-btn>
        </v-card-actions>        
      </v-card>

      <v-card v-if="this.message" class="mb-6">
        <v-card-title>
          {{ message }}
        </v-card-title>
      </v-card>

      <div>
        <v-btn
          v-if="this.gameStatus == 'complete'"
          @click="restart()"
        >
          Play Again!
        </v-btn>
      </div>
    </v-flex>
    </v-layout>
  </div>
</template>

<script>
import axios from "axios";
import question from "./question.vue";

export default {
  components: { question },
  data: () => ({
    gameStatus: 'choosing_character',
    gameId: -1,
    answerVals: ['Yes', 'No', 'Not Sure'],
    answerVal: '',
    message: '',
    question: {},
    characters: []
  }),
  created: function () {
    axios
      .get("/guess_subject/characters?game_type=Bible Characters")
      .then(response => {
        this.characters = response.data.data;
      })
  },
  methods: {
    startGame() {
      axios
        .post("/guess_subject/games", 
        {
          game_type: "Bible Characters"
        })
        .then(response => {
          const data = response.data.data;
          this.gameId = data.game_id;
          this.message = response.data.message;
          this.question = data.next_question;
          this.gameStatus = data.game_status;          
        })
        .catch(e => {
          console.log(e);
        });
    },
    processAnswer(val) {
      axios
        .post(`/guess_subject/games/${this.gameId}/process_answer`,
        {
          question_id: this.question.id,
          answer_val: val
        }).then(response => {
          const data = response.data.data;
          console.log(data);
          this.message = response.data.message;
          this.question = data.next_question;
          this.gameStatus = data.game_status;
        });
    },
    restart() {
      this.message = '';
      this.gameStatus = 'choosing_character';
    }
  }
};
  
</script>
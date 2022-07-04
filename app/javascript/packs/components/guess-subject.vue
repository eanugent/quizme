<template>
    <v-container>
      <v-row>
        <v-col xs="12">
          <v-card class="my-6 pa-3">
            <v-card-title>
              Can I read your mind?
            </v-card-title>
          </v-card>

          <v-card v-if="this.gameStatus == 'choosing_character'" class="mb-6 pa-3">
            <v-card-title>
              Choose a character from the list below
            </v-card-title>
            <v-card-text>
                <div
                  v-for="character in characters"
                  :key="character.name"
                  >
                  {{ character.name }}
                </div>          
            </v-card-text>
            <v-card-actions>
              <v-btn @click="startGame()">
                Ready to Go!
              </v-btn>
            </v-card-actions>
          </v-card>
          
          <v-card  v-if="this.gameStatus == 'in_progress'" class="mb-6 pa-5">
            <v-card-title primary-title>
              {{ question ? `${question.question}?` : ''}}
            </v-card-title>
            <v-card-actions>
              <v-btn text color="orange" @click="processAnswer(1)">Yes</v-btn>
              <v-btn text color="orange" @click="processAnswer(2)">No</v-btn>
              <v-btn text color="orange" @click="processAnswer(3)">Not Sure</v-btn>
            </v-card-actions>        
          </v-card>

          <v-card v-if="this.message" class="mb-6">
            <v-card-title>
              {{ message }}
            </v-card-title>
          </v-card>

          <v-card v-if="this.askedQuestions.length > 0" class="mb-6">
            <v-card-text>
              <div
                v-for="(question, index) in this.askedQuestions"
                :key="question.id"
                :class="`${question.color}--text`"
              >
                {{ `${index+1} ${question.text}?` }}
              </div>
            </v-card-text>
          </v-card>
          <div>
            <v-btn
              v-if="this.gameStatus == 'complete'"
              @click="restart()"
            >
              Play Again!
            </v-btn>
          </div>
        </v-col>
      </v-row>
    </v-container>
</template>

<script>
import axios from "axios";

export default {
  data: () => ({
    gameStatus: 'choosing_character',
    gameId: -1,
    answerValColors: ['green', 'red', 'amber'],
    message: '',
    question: {},
    characters: [],
    askedQuestions: []
  }),
  created: function () {
    axios
      .get("/subjects?game_type=Bible Characters")
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
      const questionLog =
        {
          text: this.question.question,
          id: this.question.id,
          color: this.answerValColors[val-1]
        };
      console.log(questionLog);
      this.askedQuestions.push(questionLog);

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
      this.askedQuestions = [];
    }
  }
};
  
</script>
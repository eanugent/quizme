<template>
    <v-container>
      <v-row>
        <v-col xs="12">
          <v-card class="my-6 pa-3">
            <v-card-title>
              Can you read my mind?
            </v-card-title>

            <v-card-text>
              I'm thinking of a Bible character from the list below. How many questions will it take you to figure out who?
            </v-card-text>
            <v-card-actions>
              <v-btn
                color="orange lighten-2"
                text
                @click="showCharacters = !showCharacters"
              >
                Character List
                <v-icon>{{ showCharacters ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
              </v-btn>
            </v-card-actions>

            <v-expand-transition>
              <div v-show="showCharacters">
                <v-divider></v-divider>

                <v-card-text>
                  <div
                  v-for="character in characters"
                  :key="character.name"
                  >
                  {{ character.name }}
                </div>   
                </v-card-text>
              </div>
            </v-expand-transition>
          </v-card>
          
          <div>
            <v-card v-if="this.gameStatus == 'in_progress'" class="mb-6 pa-5">
              <v-card-title>
                Choose a question.
              </v-card-title>
              <v-card-text
                v-for="question in this.question_options"
                :key="question.id"
              >
                {{ question.question }}?
                <v-btn
                  color="orange"
                  x-small
                  @click="processQuestion(question.id, question.question)"                
                >
                Ask
                </v-btn>
              </v-card-text>
            </v-card>

            <v-card class="mb-6">
              <v-card-title>
                {{ `${askedQuestions.length} Question${askedQuestions.length != 1 ? 's' : ''} asked` }}
              </v-card-title>
              <v-card-subtitle>
                <span class="green--text">
                  Yes
                </span> |
                <span class="red--text">
                  No
                </span> |
                <span class="amber--text">
                  Not sure
                </span>
              </v-card-subtitle>
              <v-card-text>
                <div
                  v-for="question in this.askedQuestions"
                  :key="question.id"
                  :class="`${question.color}--text`"
                >
                  {{ question.text }}?
                </div>
              </v-card-text>
            </v-card>

            <v-card v-if="this.gameStatus == 'in_progress'" class="mb-6 pa-5">
              <v-card-title>
                Ready to guess?
              </v-card-title>
                <v-card-actions>
                  <v-select
                    v-model="guess"
                    :items="characters"
                    solo
                    item-text="name"
                    item-value="id"
                    label="SELECT CHARACTER"
                    return-object
                    @change="processGuess()"
                    style="max-width: 20rem;"
                  ></v-select>
                </v-card-actions>
            </v-card>
          </div>

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
    question_options: [],
    characters: [],
    showCharacters: false,
    askedQuestions: [],
    guess: {}
  }),
  created: function () {
    axios
      .get("/subjects?game_type=Bible Characters")
      .then(response => {
        this.characters = response.data.data;
        this.startGame();
      })
  },
  methods: {
    startGame() {
      axios
        .post("/pick_subject/games", 
        {
          game_type: "Bible Characters"
        })
        .then(response => {
          const data = response.data.data;
          this.gameId = data.game_id;
          this.message = response.data.message;
          this.question_options = data.next_question_options;
          this.gameStatus = data.game_status;
        })
        .catch(e => {
          console.log(e);
        });
    },
    processQuestion(question_id, question_text) {
      axios
        .post(`/pick_subject/games/${this.gameId}/process_question`,
        {
          question_id: question_id
        }).then(response => {
          const data = response.data.data;
          console.log(data);
          this.message = response.data.message;
          this.question_options = data.next_question_options;
          this.gameStatus = data.game_status;

          const questionLog =
            {
              text: question_text,
              id: question_id,
              color: this.answerValColors[data.answer_val-1]
            };
          console.log(questionLog);
          this.askedQuestions.push(questionLog);

        });
    },
    processGuess() {
      axios
        .post(`/pick_subject/games/${this.gameId}/process_guess`,
        {
          subject_id: this.guess.id
        }).then(response => {
          const data = response.data.data;
          console.log(data);
          this.message = response.data.message;
          this.gameStatus = data.game_status;

          const questionLog =
            {
              text: `Is it ${this.guess.name}`,
              id: -1,
              color: this.answerValColors[data.answer_val-1]
            };
          console.log(questionLog);
          this.askedQuestions.push(questionLog);
          this.guess = {};
        });
    },
    restart() {
      this.message = '';
      this.askedQuestions = [];
      this.startGame();
    }
  }
};
  
</script>
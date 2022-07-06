<template>
    <v-container>      
      <v-row>
        <v-col xs="12">
          <v-card
            :color="headerColor"
            :class="`header mb-6 ${message ? 'white--text' : ''}`"
          >
            <v-card-title>
              <span
                v-if="message"
              >
                {{ message }}
              </span>
              <span
                v-else
              >
                Question {{ askedQuestions.length+1 }}/10
              </span>
            </v-card-title>
          </v-card>
          <v-card v-if="this.gameStatus == 'intro'" class="pa-3">
            <v-card-title>
              Can you read my mind?
            </v-card-title>

            <v-card-text>
              <p>
                I'm thinking of a Bible character from the list below.
                Can you guess who it is in <strong>{{ maxQuestions }} questions or less</strong>?
                After you click "READY TO GO!" below, I'll give you 3 questions to choose from. Choose the
                question that will best help you figure out my character. Keep asking questions until you're ready to "TAKE A GUESS".
                Guesses count as questions so use them carefully!
              </p>
              <h3>
                Character List
              </h3>
              <p>You can see this list again later</p>
              <div
                v-for="character in characters"
                :key="character.name"
                >
                {{ character.name }}
              </div> 
              
              <div class="mt-6">
                <v-btn @click="startGame()">
                  Ready to Go!
                </v-btn>
              </div>
            </v-card-text>           
          </v-card>
          
          <div v-if="this.gameStatus != 'intro'" >
            <v-card class="mb-6 pa-5">
              <v-card-text
                v-for="(question, index) in this.question_options"
                :key="question.id"
              >                
                <v-card
                  :color="question.disabled ? 'grey' : 'indigo'"
                  :disabled="question.disabled"
                  @click="processQuestion(index)"
                >
                  <v-card-text
                    class="white--text"
                  >
                    {{ question.question }}?
                  </v-card-text>
                </v-card>

                <v-expand-transition>
                  <v-card
                    v-if="question.answer"
                    class="transition-fast-in-fast-out v-card--reveal"
                    style="height: 100%;"
                  >
                    <v-card-text
                      :class="`${question.color}--text`"
                    >
                      {{ question.answer }}
                    </v-card-text>
                  </v-card>
                </v-expand-transition>
              </v-card-text>

              <v-card-actions>
                <v-btn
                  color="orange lighten-2"
                  text
                  @click="showAskedQuestions = !showAskedQuestions"
                >
                  Past Questions
                  <v-icon>{{ showAskedQuestions ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
                </v-btn>
              </v-card-actions>

              <v-expand-transition>
                <div v-show="showAskedQuestions">
                  <v-divider></v-divider>
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
                </div>
              </v-expand-transition>
              
              <v-card-actions>
                <v-btn
                  color="orange lighten-2"
                  text
                  @click="showCharacters = !showCharacters"
                >
                  Take a guess
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
                    class="mb-2"
                    >
                    <v-btn
                      color="orange"
                      :disabled="guessedCharacterIds.includes(character.id)"
                      x-small
                      @click="processGuess(character.id, character.name)"
                    >
                      {{ character.name }}
                    </v-btn>
                  </div>                  
                </v-card-text>
                </div>
              </v-expand-transition> 
            </v-card>
          </div>
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
    maxQuestions: 10,
    gameStatus: 'intro',
    gameId: -1,
    answerValColors: ['green', 'red', 'amber'],
    answerValText: ['Yes', 'No', 'Not sure'],
    message: '',
    question_options: [],
    showCharacters: false,
    characters: [],
    guessedCharacterIds: [],
    showAskedQuestions: false,
    askedQuestions: [],
    guess: {},
    headerColor: 'white'
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
    processQuestion(index) {
      const question = this.question_options[index];
      this.question_options.forEach((q) => {
        if(q.id != question.id){
          q.disabled = true;
        }
      });
      
      axios
        .post(`/pick_subject/games/${this.gameId}/process_question`,
        {
          question_id: question.id
        }).then(response => {
          const data = response.data.data;
          const answerIndex = data.answer_val - 1;
          this.message = this.answerValText[answerIndex];
          this.headerColor = this.answerValColors[answerIndex];

          const questionLog =
            {
              text: question.question,
              id: question.id,
              color: this.answerValColors[answerIndex]
            };
          this.askedQuestions.push(questionLog);

          setTimeout(
            () =>
              {
                this.gameStatus = data.game_status;
                this.message = '';
                this.headerColor = 'white';
                this.question_options = data.next_question_options;
              },
            3000
            );
        });
    },
    processGuess(subject_id, name) {
      this.guessedCharacterIds.push(subject_id);
      axios
        .post(`/pick_subject/games/${this.gameId}/process_guess`,
        {
          subject_id: subject_id
        }).then(response => {
          const data = response.data.data;
          this.gameStatus = data.game_status;

          if(data.answer_val == 1){
            this.message = `${name} is the right answer!`
            this.headerColor = 'green';
          }
          else if(data.answer_val == 2){
            this.message = `Not ${name}`;
            this.headerColor = 'red';
            setTimeout(
            () =>
              {
                this.message = '';
                this.headerColor = 'white';
              },
            3000
            );
          }

          const questionLog =
            {
              text: `Is it ${name}`,
              id: -1,
              color: this.answerValColors[data.answer_val-1]
            };
          
          this.askedQuestions.push(questionLog);
          this.guess = {};
        });
    },
    restart() {
      this.message = '';
      this.headerColor = 'white';
      this.askedQuestions = [];
      this.guessedCharacterIds = [];
      this.startGame();
    }
  }
};
  
</script>

<style scoped>
  .header {
    position: sticky;
    top: 64px;
    z-index: 99;
    margin: auto;
  }

  .header.feedback {
    color: white;
  }
</style>

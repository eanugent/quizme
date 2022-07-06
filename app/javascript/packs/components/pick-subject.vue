<template>
    <v-container>
      <v-row>
        <v-col xs="12">
          <v-card v-if="this.gameStatus == 'intro'" class="pa-3">
            <v-card-title>
              Can you read my mind?
            </v-card-title>

            <v-card-text>
              <p>
                I'm thinking of a Bible character from the list below.
                Can you guess who it is in <strong>{{ maxQuestions }} questions or less</strong>?
                After you click "READY TO GO!" below, I'll give you 3 questions to choose from. Click "ANSWER" beside the
                question that will best help you figure out my character. Keep asking questions until you're ready to "TAKE A GUESS".
                Guesses count as questions so use them carefully!
              </p>
              <h3>
                Character List
              </h3>
              <h4>(You'll be able to see the list again later)</h4>
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
            <!-- <v-card-actions>
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
            </v-expand-transition> -->
          </v-card>
          
          <div v-if="this.gameStatus == 'in_progress'" >
            <v-card class="mb-6 pa-5">
              <v-card-title>
                Question {{ askedQuestions.length+1 }} / 10
              </v-card-title>
              <v-card-text
                v-for="(question, index) in this.question_options"
                :key="question.id"
              >
                <!-- <span
                  :class="question.color ? `${question.color}--text` : ''"
                >
                  {{ question.question }}?
                  {{ question.answer }}
                </span> -->
                <v-card
                  color="indigo"
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
                    <!-- {{ character.name }} -->
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

            <!-- <v-card class="mb-6">
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
            </v-card> -->

            <!-- <v-card class="mb-6 pa-5">
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
            </v-card> -->
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
    processQuestion(index) {
      //this.question_options = this.question_options.filter((o) => o.id == question_id);
      const question = this.question_options[index];
      axios
        .post(`/pick_subject/games/${this.gameId}/process_question`,
        {
          question_id: question.id
        }).then(response => {
          const data = response.data.data;
          console.log(data);
          this.message = response.data.message;

          this.question_options[index].color = this.answerValColors[data.answer_val-1];
          this.question_options[index].answer = this.answerValText[data.answer_val-1];

          const questionLog =
            {
              text: question.question,
              id: question.id,
              color: this.answerValColors[data.answer_val-1]
            };
          console.log(questionLog);
          this.askedQuestions.push(questionLog);

          setTimeout(
            () =>
              {
                this.question_options = data.next_question_options;
                this.gameStatus = data.game_status;
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
          console.log(data);
          this.message = response.data.message;
          this.gameStatus = data.game_status;

          const questionLog =
            {
              text: `Is it ${name}`,
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
      this.guessedCharacterIds = [];
      this.startGame();
    }
  }
};
  
</script>
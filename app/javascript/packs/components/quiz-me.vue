<template>
    <v-container>      
      <v-row>
        <v-col xs="12">

          <!-- Mode Selection card-->
          <v-card v-if="this.gameStatus == 'mode_selection'" class="pa-3">
            <v-card-actions>
              <v-btn
                primary
              >

              </v-btn>
              <v-btn
                primary
              >

              </v-btn>
            </v-card-actions>
          </v-card>

          <!-- Intro Card -->
          <v-card v-if="this.gameStatus == 'intro'" class="pa-3">
            <v-card-title>
              Can you read my mind?
            </v-card-title>

            <v-card-text>
              <p>
                I'm thinking of a Bible character from the list below.
                Can you guess who it is in <strong>{{ maxQuestions }} questions or less</strong>?
                After you click "READY TO GO!" below, I'll give you 3 questions to choose from. Choose the
                question that will best help you figure out my character. Click "PAST QUESTIONS" to view
                questions you've previously asked. Click "TAKE A GUESS" to view the character list. When
                you think you've figured me out, click on the character to see if you've figured me out. Guesses count as 
                questions so use them carefully!
              </p>
              <h3>
                Character List
              </h3>
              <p>You can see this list again by clicking "Take a Guess"</p>
              <div
                v-for="character in characters"
                :key="character.name"
                >
                {{ character.name }}
              </div> 
              
              <div class="mt-6">
                <v-btn
                  color="success"
                  @click="startGame()"
                >
                  Ready to Go!
                </v-btn>
              </div>
            </v-card-text>           
          </v-card>
          
          <!-- Header/Message Card-->
          <v-card
            v-if="gameStatus != 'intro'"
            :color="headerColor"
            :class="`game-header mb-6 ${message ? 'white--text' : ''}`"
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
                Question {{ askedQuestions.length+1 }}/{{ maxQuestions }}
              </span>
            </v-card-title>
          </v-card>

          <!-- Game Div -->
          <div v-if="this.gameStatus != 'intro'" >

            <!-- Question Area -->
            <v-card class="mb-6 pa-5">
              <div
                v-if="gameStatus=='in_progress'"
              >
                <div
                  v-if="askedQuestions.length+1 < maxQuestions"
                >
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
                  </v-card-text>
                </div>
                <div
                  v-else
                >
                  <h2>
                    Time to take a guess below!
                  </h2>
                </div>
              </div>
              <div
                v-else-if="guessedCharacterIds.includes(correctCharacterId)"
              >
                <h2>
                  <span
                    v-if="askedQuestions.length / maxQuestions > .8"
                  >
                    Whew! Just made it in {{askedQuestions.length}} questions!
                  </span>
                  <span
                    v-else-if="askedQuestions.length / maxQuestions > .5"
                    >
                    {{askedQuestions.length}} questions, not bad.
                  </span>
                  <span
                    v-else
                  >
                    Unbelievable! Only {{askedQuestions.length}} questions?!?! Amazing!
                  </span>
                </h2>
              </div>
              

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
                    class="mb-4"
                    >
                    <h3
                      v-if="correctCharacterId == character.id"
                      class="green lighten-3 white--text pa-3"
                    >
                      {{ character.name }}
                    </h3>
                    <v-btn
                      v-else
                      color="orange"
                      small
                      :disabled="guessedCharacterIds.includes(character.id) || gameStatus != 'in_progress'"
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
        <div
          v-if="this.gameStatus == 'complete'"
        >
          <v-btn
            color="success"
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
import consumer from "../../channels/consumer"

export default {
  data: () => ({
    maxQuestions: 10,
    gameStatus: 'intro',
    gameId: null,
    answerValTextColors: ['green', 'red', 'amber'],
    answerValBgColors: ['green lighten-2', 'red lighten-1', 'amber lighten-2'],
    answerValText: ['Yes', 'No', 'Not sure'],
    message: '',
    question_options: [],
    showCharacters: false,
    characters: [],
    guessedCharacterIds: [],
    correctCharacterId: -1,
    showAskedQuestions: false,
    askedQuestions: [],
    processing: false,
    guess: {},
    headerColor: 'white'
  }),
  created: function () {
    axios
      .get("/subjects?game_type=Bible Characters")
      .then(response => {
        this.characters = response.data.data;
      });

    this.gameId = gon.game_id;
  },
  channels: {
    GameChannel: {
      connected(){
        console.log("connected with actioncable-vue");
      },
      rejected() {},
      received(data) {
        console.log('Received data: ');
        console.log(data);
      },
      disconnected() {}
    }
  },
  methods: {
    startGame() {
      axios
        .post("/pick_subject/games", 
        {
          game_type: "Bible Characters",
          id: this.gameId
        })
        .then(response => {
          const data = response.data.data;
          this.gameId = data.game_id;

          this.$cable.subscribe({
            channel: "GameChannel",
            game_id: this.gameId
          });

          this.question_options = data.next_question_options;
          this.gameStatus = data.game_status;
        })
        .catch(e => {
          console.log(e);
        });
    },
    processQuestion(index) {
      if(this.processing) return;
      this.processing = true;
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
          this.headerColor = this.answerValBgColors[answerIndex];

          const questionLog =
            {
              text: question.question,
              id: question.id,
              color: this.answerValTextColors[answerIndex]
            };
          this.askedQuestions.push(questionLog);

          setTimeout(
            () =>
              {
                this.gameStatus = data.game_status;
                if(this.gameStatus == 'complete') {
                  this.correctCharacterId = data.correct_subject_id;
                  const character = this.characters.find(c => c.id == data.correct_subject_id);
                  this.message = `It was ${character.name}`;
                  this.headerColor = this.answerValBgColors[1];
                }
                else{
                  this.message = '';
                  this.headerColor = 'white';
                  this.question_options = data.next_question_options;
                }
                this.processing = false;
              },
            1000
            );
        });
    },
    updateQuestions(data) {
      
    },
    processGuess(subject_id, name) {
      if(this.processing) return;
      this.processing = true;
      this.guessedCharacterIds.push(subject_id);
      axios
        .post(`/pick_subject/games/${this.gameId}/process_guess`,
        {
          subject_id: subject_id
        }).then(response => {
          const data = response.data.data;
          this.gameStatus = data.game_status;
          this.correctCharacterId = data.correct_subject_id

          if(data.answer_val == 1){
            this.message = `${name} is the right answer!`
            this.headerColor = this.answerValBgColors[0];
            this.processing = false;
          }
          else if(data.answer_val == 2){
            this.message = `Not ${name}`;
            this.headerColor = this.answerValBgColors[1];
            setTimeout(
            () =>
              {
                if(this.gameStatus == 'complete'){
                  this.correctCharacterId = data.correct_subject_id;
                  const character = this.characters.find(c => c.id == data.correct_subject_id);
                  this.message = `It was ${character.name}`;
                  this.headerColor = 'red';
                }
                else{
                  this.message = '';
                  this.headerColor = 'white';
                }
                this.processing = false;
              },
            2000
            );
          }

          const questionLog =
            {
              text: `Is it ${name}`,
              id: -1 * subject_id,
              color: this.answerValTextColors[data.answer_val-1]
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
      this.correctCharacterId = -1;
      this.gameId = null;
      this.startGame();
    }
  }
};
  
</script>
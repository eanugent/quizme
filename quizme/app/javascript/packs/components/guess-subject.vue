<template>
  <div>
    <h3>
        Guess Subjects
    </h3>
    <div>
      {{ questionText }}
    </div>
    <div>
      <v-container>
        <v-radio-group v-model="answerVal">
        <v-radio
          v-for="(answer, index) in answerVals"
          :key="index+1"
          :label="answer"
          :value="index+1"
        ></v-radio>
        </v-radio-group>
      </v-container>
    </div>
    <div>
      {{ message }}
    </div>
  </div>
</template>

<script>
import axios from "axios";
import question from "./question.vue";

export default {
  components: { question },
  data: () => ({
    gameStatus: 'uninitialized',
    answerVals: ['Yes', 'No', 'Not Sure'],
    answerVal: '',
    message: '',
    questionText: ''
  }),
  computed: {
    formTitle() {
      return this.editedIndex === -1 ? "New Item" : "Edit Item";
    }
  },
  created() {
    this.initialize();
  },
  methods: {
    initialize() {
      return axios
        .get("/users")
        .then(response => {
          console.log(response.data);
          this.desserts = response.data;
        })
        .catch(e => {
          console.log(e);
        });
    },
    editItem(item) {
      this.editedIndex = item.id;
      this.editedItem = Object.assign({}, item);
      this.dialog = true;
    },
    deleteItem(item) {
      const index = this.desserts.indexOf(item);
      confirm("Are you sure you want to delete this item?");
      axios
        .delete(`http://localhost:3000/users/${item.id}`)
        .then(response => {
          console.log(response);
          console.log(response.data.json);
          alert(response.data.json);
          this.initialize();
        })
        .catch(error => {
          console.log(error);
        });
      this.desserts.splice(index, 1);
    },
    close() {
      this.dialog = false;
      setTimeout(() => {
        this.editedItem = Object.assign({}, this.defaultItem);
        this.editedIndex = -1;
      }, 300);
    },
    save(item) {
      if (this.editedIndex > -1) {
        axios
          .put(`http://localhost:3000/users/${item.id}`, {
            id: this.editedItem.id,
            first_name: this.editedItem.first_name,
            last_name: this.editedItem.last_name,
            email: this.editedItem.email,
            phone: this.editedItem.phone,
            address: this.editedItem.address
          })
          .then(response => {
            console.log(response);
            this.initialize();
          })
          .catch(error => {
            console.log(error);
          });
      } else {
        console.log(item);
        axios
          .post(`http://localhost:3000/users/`, {
            user: this.editedItem
          })
          .then(response => {
            console.log(response);
            console.log("Created!");
            this.initialize();
          })
          .catch(error => {
            console.log(error);
          });
        this.desserts.push(this.editedItem);
      }
      this.close();
    },
    getUser(item) {
      axios
        .get(`http://localhost:3000/${item.id}`)
        .then(response => {
          this.dessert = response.data;
        })
        .catch(error => {
          console.log(error);
        });
    }
  }
};
  
</script>
<template>
    <p>
        {{ questionText }}
    </p>
</template>

<script>
//import { defineComponent } from '@vue/composition-api'

export default {
    data: function() {
        return {
            questionText: "Who are you?"
        }
    },
}
</script>

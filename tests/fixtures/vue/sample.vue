<script>
console.log("hello");
console.log("hello");
</script>

<script lang="jsx">
import {
  VNode
} from "vue"
export default {
  computed: {
    foo() {
      return "foo"
    },
  },
  render(h) {
    return (
      <div>
        MARKER
        {this.foo}
      </div>
    )
  },
}
</script>

<template>
  MARKER
  <br />
  <footer>
    MARKER
    foo
    <br />
  </footer>
</template>

<style lang="css">
footer {
  background: #00abc9;
}
footer {
  background: #00abc9;
}
</style>


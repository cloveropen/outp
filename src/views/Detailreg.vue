<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <helloworld />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import helloworld from "../components/spacer";
export default {
  components: {
    Basepage,
    helloworld
  }
};
</script>

<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <detailundo />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import detailundo from "../components/DetailundoC";
export default {
  components: {
    Basepage,
    detailundo
  }
};
</script>

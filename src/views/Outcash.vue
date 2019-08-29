<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <outcash />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import outcash from "../components/OutcashC";
export default {
  components: {
    Basepage,
    outcash
  }
};
</script>

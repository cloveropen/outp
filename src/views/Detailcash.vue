<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <detailcash />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import detailcash from "../components/DetailcashC";
export default {
  components: {
    Basepage,
    detailcash
  }
};
</script>

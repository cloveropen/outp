<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <detailop />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import detailop from "../components/DetailopC";
export default {
  components: {
    Basepage,
    detailop
  }
};
</script>

<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <outchk />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import outchk from "../components/OutchkC";
export default {
  components: {
    Basepage,
    outchk
  }
};
</script>

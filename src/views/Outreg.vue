<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />    
    <v-container fluid fill-height>
      <v-layout justify-start>
        <outreg />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import outreg from "../components/OutregC";
export default {
  components: {
    Basepage,
    outreg
  }
};
</script>

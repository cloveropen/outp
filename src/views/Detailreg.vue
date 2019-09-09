<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <detailreg />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import detailreg from "../components/DetailregC";
export default {
  components: {
    Basepage,
    detailreg
  }
};
</script>

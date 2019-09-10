<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <detailchk />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import detailchk from "../components/DetailchkC";
export default {
  components: {
    Basepage,
    detailchk
  }
};
</script>

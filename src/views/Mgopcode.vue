<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <mgdict />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import mgdict from "../components/MgopcodeC";
export default {
  components: {
    Basepage,
    mgdict
  }
};
</script>

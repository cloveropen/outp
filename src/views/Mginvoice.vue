<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start>
        <mginvoice />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import mginvoice from "../components/MginvoiceC";
export default {
  components: {
    Basepage,
    mginvoice
  }
};
</script>

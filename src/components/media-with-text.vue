<template>
  <v-card
    class="mx-auto"
    max-width="99%"
    min-width="100%"
  >
    <v-img
      class="white--text"
      height="100px"
      :src="require('../assets/outreg.jpg')"
    >
      <v-card-title class="align-end fill-height">门诊挂号</v-card-title>
    </v-img>

    <v-card-text>
      <span>Number 10</span><br>
      <span class="text--primary">
        <span>Whitehaven Beach</span><br/>
        <span>Whitsunday Island, Whitsunday Islands</span>
      </span>
    </v-card-text>

    <v-card-actions>
      <v-btn
        text
        color="orange"
      >
        Share
      </v-btn>
      <v-btn
        text
        color="orange"
      >
        Explore
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

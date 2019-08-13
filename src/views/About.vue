<template>
  <v-container fluid class="pa-0">
    <div class="about">
      <h1>This is an about page</h1>
    </div>
    <v-layout wrap>
      <v-flex xs12>
        <p>Normal</p>
      </v-flex>

      <v-flex xs12 sm3>
        <v-btn text icon color="pink">
          <v-icon>favorite</v-icon>
        </v-btn>
      </v-flex>

      <v-flex xs12 sm3>
        <v-btn text icon color="indigo">
          <v-icon>star</v-icon>
        </v-btn>
      </v-flex>

      <v-flex xs12 sm3>
        <v-btn text icon color="green">
          <v-icon>cached</v-icon>
        </v-btn>
      </v-flex>

      <v-flex xs12 sm3>
        <v-btn text icon color="deep-orange">
          <v-icon>thumb_up</v-icon>
        </v-btn>
      </v-flex>
       <v-icon>mdi-anchor</v-icon>

    <v-icon>thumb_up</v-icon>

    <v-icon>cached</v-icon>

    <v-icon>mdi-tilde</v-icon>

    <v-icon>favorite</v-icon>

    <v-icon>mdi-mouse</v-icon>
    </v-layout>
  </v-container>
</template>

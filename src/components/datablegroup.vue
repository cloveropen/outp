<template>
  <v-container class="grey lighten-5">
    <v-container>
        <h1>Grouping Table Demo</h1>
https://github.com/lzhoucs/vuetify">my vuetify folk</a>, which is published on <a target="_blank" href="https://www.npmjs.com/package/@lzhoucs/vuetify">npm</a>. Also checkout <a target="_blank" href="https://codepen.io/lzhoucs/pen/dqZv        <p>Note: fixed columns and grouping tables below are added only in <a target="_blank" href="Xr">fixed columns table demo</a></p>
        
        <div class="section">
          <h2>Grouping Table - collapsed by default</h2>
          <v-data-table :headers="headers" :items="desserts" hide-actions item-key="name" group-key="category">

            <template slot="group" slot-scope="props">
              <span class="font-weight-bold">
                Group {{props.groupIndex + 1}} - {{props.groupName}}
              </span>
            </template>

            <template slot="items" slot-scope="props">
              <tr>
                <td>{{ props.item.name }}</td>
                <td>{{ props.item.calories }}</td>
                <td>{{ props.item.fat }}</td>
                <td>{{ props.item.carbs }}</td>
                <td>{{ props.item.protein }}</td>
                <td>{{ props.item.iron }}</td>
              </tr>
            </template>

          </v-data-table>
        </div>

        <div class="section">
          <h2>Grouping Table - expanded by default</h2>
          <v-data-table :headers="headers" :items="desserts" hide-actions item-key="name" group-key="category" group-expanded>

            <template slot="group" slot-scope="props">
              <span class="font-weight-bold">
                Group {{props.groupIndex + 1}} - {{props.groupName}}
              </span>
            </template>

            <template slot="items" slot-scope="props">
              <tr>
                <td>{{ props.item.name }}</td>
                <td>{{ props.item.calories }}</td>
                <td>{{ props.item.fat }}</td>
                <td>{{ props.item.carbs }}</td>
                <td>{{ props.item.protein }}</td>
                <td>{{ props.item.iron }}</td>
              </tr>
            </template>

          </v-data-table>
        </div>
        
        <div class="section">
          <h2>Grouping Table with custom expand icon</h2>
          <v-data-table :headers="headers" :items="desserts" hide-actions item-key="name" group-key="category" expand-icon="arrow_drop_up">

            <template slot="group" slot-scope="props">
              <span class="font-weight-bold">
                Group {{props.groupIndex + 1}} - {{props.groupName}}
              </span>
            </template>

            <template slot="items" slot-scope="props">
              <tr>
                <td>{{ props.item.name }}</td>
                <td>{{ props.item.calories }}</td>
                <td>{{ props.item.fat }}</td>
                <td>{{ props.item.carbs }}</td>
                <td>{{ props.item.protein }}</td>
                <td>{{ props.item.iron }}</td>
              </tr>
            </template>

          </v-data-table>
        </div>

        <div class="section">
          <h2>Grouping Table with expand/collapse all</h2>

          <v-btn color="primary" small @click="collapseAll">Collapse All</v-btn>
          <v-btn color="secondary" small @click="expandAll">Expand All</v-btn>

          <v-data-table ref="expandableTable" :headers="headers" :items="desserts" hide-actions item-key="name" group-key="category">

            <template slot="group" slot-scope="props">
              <span class="font-weight-bold">
                Group {{props.groupIndex + 1}} - {{props.groupName}}
              </span>
            </template>

            <template slot="items" slot-scope="props">
              <tr>
                <td>{{ props.item.name }}</td>
                <td>{{ props.item.calories }}</td>
                <td>{{ props.item.fat }}</td>
                <td>{{ props.item.carbs }}</td>
                <td>{{ props.item.protein }}</td>
                <td>{{ props.item.iron }}</td>
              </tr>
            </template>

          </v-data-table>
        </div>
        
        <div class="section">
          <h2>Grouping Table with group sort order</h2>
          <v-btn small color="primary" @click="groupSortDescending = !groupSortDescending">{{groupSortDescending ? 'desc' : 'asc'}}</v-btn>
          
          <v-data-table :headers="headers" :items="desserts" hide-actions item-key="name" group-key="category"
                        :group-sort-descending="groupSortDescending">

            <template slot="group" slot-scope="props">
              <span class="font-weight-bold">
                Group {{props.groupIndex + 1}} - {{props.groupName}}
              </span>
            </template>

            <template slot="items" slot-scope="props">
              <tr>
                <td>{{ props.item.name }}</td>
                <td>{{ props.item.calories }}</td>
                <td>{{ props.item.fat }}</td>
                <td>{{ props.item.carbs }}</td>
                <td>{{ props.item.protein }}</td>
                <td>{{ props.item.iron }}</td>
              </tr>
            </template>

          </v-data-table>
        </div>
      </v-container>
  </v-container>
</template>

<script>
export default {
methods: {
      collapseAll() {
        this.$refs.expandableTable.collapseAll()
      },
      expandAll() {
        this.$refs.expandableTable.expandAll()
      }
    },
    data: () => ({
      headers: [
        { text: "Dessert (100g serving)", value: "name" },
        { text: "Calories", value: "calories" },
        { text: "Fat (g)", value: "fat" },
        { text: "Carbs (g)", value: "carbs" },
        { text: "Protein (g)", value: "protein" },
        { text: "Iron (%)", value: "iron" }
      ],
      desserts: [
        {
          value: false,
          name: "Orange Juice",
          category: "Beverage",
          calories: 262,
          fat: 16.0,
          carbs: 23,
          protein: 6.0,
          iron: "7%"
        },
        {
          value: false,
          name: "Larabar",
          category: "Snack",
          calories: 408,
          fat: 3.2,
          carbs: 87,
          protein: 6.5,
          iron: "45%"
        },
        {
          value: false,
          name: "Donut",
          category: "Breakfast",
          calories: 452,
          fat: 25.0,
          carbs: 51,
          protein: 4.9,
          iron: "22%"
        },

        {
          value: false,
          name: "Bagel",
          category: "Breakfast",
          calories: 999,
          fat: 28.0,
          carbs: 151,
          protein: 2.9,
          iron: "29%"
        },
        {
          value: false,
          name: "KitKat",
          category: "Snack",
          calories: 518,
          fat: 26.0,
          carbs: 65,
          protein: 7,
          iron: "6%"
        }
      ],
      groupSortDescending: false
    })
}
</script>
<style>
.section {
  margin-top: 50px;
}
</style>
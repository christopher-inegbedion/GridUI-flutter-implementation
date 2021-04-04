# Flutter GridUI implentation

An implementation of the grid layout system with Flutter.
#### Disclaimer: The column is horizontal, row is vertical. 
## What is GridUI?
GridUI is a design system that allows blocks containing content to be created/deleted/moved around as required to form a cohesive layout.

GridUI works by converting data in a matrix stored on the layout server into a standard JSON string object and then using that data to create the UI layout. The matrix determines the size and position of each combined block. An empty space in the 2D matrix is labelled with a '0' and a combined block will instead be marked with a 1, 2, 3...etc. 

**Example**: The diagram below is a 3x3 matrix with no combined block.
```
    1   2   3
  -------------
1 | 0 | 0 | 0 |
  -------------
2 | 0 | 0 | 0 |
  -------------
3 | 0 | 0 | 0 |
  -------------
```
**Example**: The diagram below is a 5x5 matrix with a 2x2 combined block at position (2,2. The first 2 is the column, the second 2 is the row). The parts of the matrix with the combined block is marked with a '1'.
```
    1   2   3   4   5
  ---------------------
1 | 0 | 0 | 0 | 0 | 0 |
  ---------------------
2 | 0 | 1 | 1 | 0 | 0 |
  ---------------------
3 | 0 | 1 | 1 | 0 | 0 |
  ---------------------
4 | 0 | 0 | 0 | 0 | 0 |
  ---------------------
5 | 0 | 0 | 0 | 0 | 0 |
  ---------------------

END
```

**Example**: The diagram below is a 5x5 matrix with a 2x2 combined block at position (1,1) and a 1x3 combined block at position (4,3). The parts of the matrix with a combined block is marked with a '1'.
```
    1   2   3   4   5
  ---------------------
1 | 1 | 1 | 0 | 0 | 0 |
  ---------------------
2 | 1 | 1 | 0 | 0 | 0 |
  ---------------------
3 | 0 | 0 | 0 | 0 | 0 |
  ---------------------
4 | 0 | 0 | 1 | 1 | 1 |
  ---------------------
5 | 0 | 0 | 0 | 0 | 0 |
  ---------------------

END
```
## How the GridUI client receives the layout data?
The layout for a GridUI client is determined by the JSON string object received from the GridUI layout server. The data in the matrix is converted into a JSON string object which describes its size, position in the Grid, its content, etc. This JSON data is then sent to a GridUI client that is able to understand the JSON and convert it into a layout
```
-----------------       JSON          -----------------
|    SERVER     | ------------------> |     CLIENT    |
-----------------                     -----------------

END
```

## How is the layout updated?
When an update to the Grid is made, the potential change to be made is sent to the layout server with the change details and then the new changes are re-calculated server-side and sent back to the GridUI client as a full JSON string object which is then re-updated with a new layout.

```
(1) Change is made
-------------------------------------                        
|            CLIENT                 | (API request)          --------------------
|   (Combined block is deleted)     | ---------------------->|      SERVER      |
-------------------------------------                        --------------------

(2) Changes are re-calculated
---------------------------------
|       SERVER                  | (JSON string is re-generated)
|   (Change has been received)  | -------------------------------> JSON string
---------------------------------

(3) JSON string is sent back to client
---------------------      JSON     --------------------
|       SERVER      | ------------> |      CLIENT      |
---------------------               --------------------

END
```

## What is the layout of the JSON received from the server?
The structure of the GridUI JSON and each property definition is as follows:
```
Grid object = {
    "grid_columns": This is the total amount of columns in the grid 

    "grid_rows": This is the amount of rows in the grid

    "combined_groups": This is an array that contains the data for each combined block. [

        ~~~This array contains multiple combined groups~~~
        What is a combined group?: Each combined block is grouped with other combined blocks
        that are adjacent to it horizontally. A combined group is therefore a collection of
        horizontally adjacent combined blocks.

        {
      "combined_group_type": This describes the type of combined group

      "columns_above": This is the number of empty blocks above the combined group.
       If a combined group A is below another combined group B, then the number of
       columns above for A will be the number of columns above before reaching B,

      "columns_below": This is the number of empty blocks below the combined group.
      This value is always 0 if the combined group is not the last in the array, 
      else it will be the number of blocks before the end of the grid.

      "number_of_columns": This is the maximum amount of column space occupied by the blocks in
      the combined group,

      "number_of_rows": This value is the same as the number of rows in the grid,
      
      "combined_blocks": This property describes each individual combined block in the combined group [

          ~~~This array contains each combined block in the combined group~~~

        {

          "number_of_rows_left": This is the number of empty rows to the left of a combined block before another combined block,

          "number_of_rows_right": This is the number of empty rows to the right of a combined block before another combined block

          "number_of_columns_above": This is the number of empty columns above a combined block in the combined group

          "number_of_columns_below": This is the number of empty columns below a combined block in the combined group

          "position_in_combined_group": This is the positional index of a combined block in its combined group.
           The first combined block from the left is 1, second 2, etc.
          
          "block": This describes the properties of a combined block in detail {

            "uuid": This identifies the block in the grid. Used to assign the blocks content
              
            "type": This is the type of combined block

            "content": This describes what type of content the combined block is to display (More on this below)
            
            "number_of_rows": This describes the number of rows the combined block occupies (Its width)

            "number_of_columns": This describes the number of columns the combined block occupies (Its height)

            "combined_group_position": --

            "block_position": --
          }
        }
      ]
    }
        
    ]
}

END
```

## Block content
Each block has a type of content that describes what it displays. These include:
- Text
- Color
- Image
- Video
- etc...

Each of the content types have their own unique data structure.

#### Text
```
TextContent content {
    "block_id": This is the UUID for the content's combined block

    "value": This will be the text to be displayed in the block. (String)

    "position": This is the position of the text in the combined block. The possible range of values are from 1-9, with each
    number representing a different position in the combined block.
    -------------
    | 1 | 2 | 3 |
    -------------
    | 4 | 5 | 6 |
    -------------
    | 7 | 8 | 9 |
    -------------

    "font-size": This is the size of the combined block. (Int)

    "color": This is the color of the text. Hex representation is used. (String)

    "font": This is the type of font used to display the text (String)
}

END
```

...more to come

### How do the blocks in the matrix know which content is theirs?
Each block is given a UUID to identify it and that UUID is stored in the block content object

## Data transfer diagram
How is the data transfered from the server to the client, vice-versa.
```
  +---------------------------------------------------------------------------+         +------------------------------------------------------------------------------------+
  |                         Server side                                       |         |                                  Client side                                       |
  |  +----------+     +---------------+     +------------------------------+  |  JSON   |  +--------------+     +---------------+     +-------------------+     +----------+ |
  |  |  Matrix  | <-> |  Grid object  | <-> |  JSON string representation  |  | <-----> |  | JSON string  | <-> |  Grid object  | <-> |  GridView object  | <-> |  Layout  | |
  |  +----------+     +---------------+     +------------------------------+  |         |  +--------------+     +---------------+     +-------------------+     +----------+ |
  +---------------------------------------------------------------------------+         +------------------------------------------------------------------------------------+

END
```
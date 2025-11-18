/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package me.ai15kec.activity;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author hammercroft
 */
class ViewOrderableItems {

    static void call() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
    
    static void printListOfItems(){
        System.out.println("LIST OF ITEMS:");
        System.out.print(Ansi.ITALIC+Ansi.BG_BLUE);
        final int COLS = 5;     // five columns
        final int ROWS = 12;
        final int CELL_WIDTH = 12;
        final int GAP = 2;      // two-space padding between columns
        final int INDENT = 2;   // two spaces at start of each line
        int totalCells = COLS * ROWS;
        List<String> items = new ArrayList<>(OrderingSystem.inventory);
        // Fill blanks with empty cells
        while (items.size() < totalCells) {
            items.add("            "); // blank (12 spaces)
        }
        for (int row = 0; row < ROWS; row++) {
            System.out.print(" ".repeat(INDENT)); // left indent
            for (int col = 0; col < COLS; col++) {
                int idx = row * COLS + col;
                String item = items.get(idx);
                // Compute visible length 
                int pad = CELL_WIDTH - item.length();
                if (pad < 0) {
                    pad = 0;
                }
                System.out.print(item);
                System.out.print(" ".repeat(pad)); // pad inside cell
                if (col < COLS - 1) {
                    System.out.print(" ".repeat(GAP)); // gap between columns
                }
            }
            System.out.println();
        }
        System.out.println(Ansi.RESET);
    }
    
}

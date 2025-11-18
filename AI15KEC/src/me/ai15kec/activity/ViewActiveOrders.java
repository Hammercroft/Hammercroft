/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package me.ai15kec.activity;

/**
 *
 * @author hammercroft
 */
class ViewActiveOrders {

    static void call() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
    
    static void printListOfOrders(){
        System.out.println("LIST OF ORDERS:");
        System.out.print(Ansi.ITALIC+Ansi.BG_BLUE);
        for (int i = 0; i < OrderingSystem.activeOrders.size(); i++) {
            Order order = OrderingSystem.activeOrders.get(i);
            StringBuilder sb1 = new StringBuilder("            ");
            String orderText = sb1.replace(0, 11, order.itemId).toString();
            StringBuilder sb2 = new StringBuilder("   ");
            String orderIdText = sb2.replace(0, 2, Integer.toString(i+1)).toString();
            System.out.print("  Order "+Ansi.BOLD+orderIdText+Ansi.RESET+Ansi.ITALIC+Ansi.BG_BLUE+" | "+orderText+ " | ");
            long elapsedMillis = System.currentTimeMillis() - order.timeCreated;
            double minutes = elapsedMillis / 60000;
            System.out.print((Math.round(minutes*100.0)/100.0)+"m ago, for ");
            if (order.recipientDisplay.equals("SEE"))
                System.out.print(Ansi.BOLD+order.recipient+Ansi.RESET+Ansi.ITALIC+Ansi.BG_BLUE);
            else
                System.out.println("Table "+Ansi.BOLD+order.recipient+Ansi.RESET+Ansi.ITALIC+Ansi.BG_BLUE);
        }
        
        System.out.println(Ansi.RESET);
    }
    
}

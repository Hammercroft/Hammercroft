/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package me.ai15kec.activity;

import static me.ai15kec.activity.EnterOrder.renderUpper;

/**
 *
 * @author hammercroft
 */
class DeleteOrder {

    static void call() {
        OrderingSystem.clearTerminal();
        renderUpper();
        while (true) {
            System.out.println("(You may need to scroll to see the full list.)");
            System.out.print("Enter an Order ID to remove (or enter nothing to exit): ");
            OrderingSystem.input = OrderingSystem.scn.nextLine();

            if (OrderingSystem.input.isBlank()) {
                return;
            }
            
            try {
                int index = Integer.parseInt(OrderingSystem.input.trim());
                // safe to use index here
                Order order = OrderingSystem.activeOrders.get(index - 1);
                OrderingSystem.activeOrders.remove(order);
                break;
            } catch (NumberFormatException | IndexOutOfBoundsException e) {
                OrderingSystem.clearTerminal();
                renderUpper();
                System.out.println("You have entered an invalid Order ID.");
            }
        }

        OrderingSystem.clearTerminal();
        renderUpper();
        System.out.println("Order deleted. Press ENTER to continue...");
        OrderingSystem.scn.nextLine();
    }
    
    static void renderUpper() {
        System.out.println(Ansi.BG_BLUE + Ansi.BRIGHT_YELLOW + "LNU Cafeteria Ordering System          \n" + Ansi.RESET);
        System.out.println(Ansi.BG_BRIGHT_YELLOW + Ansi.MAGENTA + "(Delete Order)" + Ansi.RESET);
        ViewActiveOrders.printListOfOrders();
    }
}

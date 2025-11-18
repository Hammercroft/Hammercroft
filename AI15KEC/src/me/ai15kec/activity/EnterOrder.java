package me.ai15kec.activity;

import java.util.ArrayList;
import java.util.List;

public class EnterOrder {

    static void call() {
        while (true) {
            OrderingSystem.clearTerminal();
            renderUpper();

            String item;
            while (true) {
                System.out.print("Please enter the requested item. Enter nothing to exit: ");
                OrderingSystem.input = OrderingSystem.scn.nextLine();

                if (OrderingSystem.input.isBlank()) {
                    return;
                }

                item = resolveItemName(); // uses OrderingSystem.input

                if (item != null && OrderingSystem.inventory.contains(item.toLowerCase())) {
                    break;
                }

                OrderingSystem.clearTerminal();
                renderUpper();
                System.out.println("You have entered an invalid item.");
            }

            int amount = -1;
            boolean firstAttempt = true;

            while (amount == -1) {
                OrderingSystem.clearTerminal();
                renderUpper();

                if (!firstAttempt) {
                    System.out.println("You have entered an invalid amount.");
                    System.out.println("If you need to exit now, enter 0.");
                }

                System.out.print("How many of " + Ansi.BRIGHT_MAGENTA + item + Ansi.RESET + "? ");
                OrderingSystem.input = OrderingSystem.scn.nextLine();
                firstAttempt = false;

                if (OrderingSystem.input.isBlank()) {
                    continue;
                }

                try {
                    int test = Integer.parseInt(OrderingSystem.input.trim());
                    if (test == 0) {
                        return;
                    }
                    if (test > 0) {
                        amount = test;
                    }
                } catch (NumberFormatException e) {
                    // handled by loop retry
                }
            }

            String recipient = "";
            firstAttempt = true;

            while (recipient.isBlank()) {
                OrderingSystem.clearTerminal();
                renderUpper();

                if (!firstAttempt) {
                    System.out.println("Please enter something. (Or type EXIT to exit this menu...)");
                }

                System.out.print("Enter table number or recipient info: ");
                recipient = OrderingSystem.scn.nextLine().trim();

                if (recipient.equalsIgnoreCase("EXIT")) {
                    return;
                }
                firstAttempt = false;
            }

            Order order = new Order(item, amount, recipient);
            OrderingSystem.orderHistory.add(order);
            OrderingSystem.activeOrders.add(order);
            
            OrderingSystem.clearTerminal();
            renderUpper();
            System.out.println("Order created. Press ENTER to continue...");
            OrderingSystem.scn.nextLine();
        }
    }

    static void renderUpper() {
        System.out.println(Ansi.BG_BLUE + Ansi.BRIGHT_YELLOW + "LNU Cafeteria Ordering System          \n" + Ansi.RESET);
        System.out.println(Ansi.BG_BRIGHT_YELLOW + Ansi.MAGENTA + "(Enter Order)" + Ansi.RESET);

        ViewOrderableItems.printListOfItems();
        System.out.println(Ansi.BRIGHT_BLUE + Ansi.BOLD + "There are currently " + OrderingSystem.activeOrders.size() + " active order items." + Ansi.RESET);
        System.out.println(Ansi.BRIGHT_BLUE + Ansi.BOLD + OrderingSystem.orderHistory.size() + " orders for items has been made so far." + Ansi.RESET);
    }

    private static String resolveItemName() {
        String input = OrderingSystem.input.trim().toLowerCase();

        List<String> matches = new ArrayList<>();
        for (String item : OrderingSystem.inventory) {
            if (item.startsWith(input)) {
                matches.add(item);
            }
        }

        if (matches.isEmpty()) {
            return null;
        } else if (matches.size() == 1) {
            return matches.get(0);
        } else {
            return null;
        }
    }
}

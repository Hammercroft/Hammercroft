package me.ai15kec.activity;

import java.io.Console;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

//just a school activity
//Procedural Java - dont mind the `static` overuse

/*
Instructions from instructor:

Create an ordering system for LNU Cafeteria. 
1. Must accept username and password. Validate inputs. Provide appropriate message if valid or invalid. 
2. If login credentials are valid, display options such as add order, view orders, delete orders, exit. (You can modify the menu)
3. Make each menu functional.
 */
public class OrderingSystem {

    public static final Scanner scn = new Scanner(System.in);
    public static String input;
    public static volatile String status = "";
    public static volatile long statusChangedTick = 0;
    public static volatile boolean loggedIn = false;
    public static volatile boolean shouldRefresh = true;

    public static final List<String> inventory = new ArrayList<>();
    public static final List<Order> activeOrders = new ArrayList<>();
    public static final List<Order> orderHistory = new ArrayList<>();

    // array of username & password string pairs
    final static String[][] accounts = {
        {"kec", "12345678"},
        {"rafaela", "SanacionParaTodos"},
        {"estes", "SanacionSoloParaMi"},
        {"carmilla", "MatarEsMejor"},
        {"uranus", "HitMeBabyOneMoreTime"},
        {"floryn", "Sanacion"},
        {"yve", "damageForTheeButNotForMe"},
        {"hammercroft", "dumbell1"},};

    public static void main(String... args) {
        //rich terminal features (needed for hiding passwords)
        Console console = System.console();
        if (console == null) {
            System.err.println("No console available. Please run this program in a standard terminal.");
            System.exit(1);
        }

        //login
        System.out.println("Please log in to access the LNU Cafeteria ordering system.");
        while (!loggedIn) {
            String username = console.readLine("Username: ");
            boolean userFound = false;
            for (String[] pair : accounts) {
                if (!pair[0].equalsIgnoreCase(username)) {
                    continue;
                }
                userFound = true;
                while (true) {
                    char[] pwChars = console.readPassword("Password: ");
                    String password = new String(pwChars);
                    if (pair[1].equals(password)) {
                        loggedIn = true;
                        break;
                    }
                    System.out.println("Incorrect password. Try again.");
                }
                break;
            }
            if (!userFound) {
                System.out.println("Username not found. Try again.\n");
            }
        }
        System.out.println("Logged in!");
        clearTerminal();

        inventory.add("coke250ml");
        inventory.add("coke1000ml");
        inventory.add("coke1500ml");
        inventory.add("sprite250ml");
        inventory.add("sprite1000ml");
        inventory.add("sprite1500ml");
        inventory.add("royal250ml");
        inventory.add("royal1000ml");
        inventory.add("royal1500ml");
        inventory.add("nspring250ml");
        inventory.add("minutemaid");
        inventory.add("burgerb1t1");
        inventory.add("chburgerb1t1");
        inventory.add("friedchicken");
        inventory.add("giniling");
        inventory.add("longganisa");
        inventory.add("meatball");
        inventory.add("maling");
        inventory.add("carbonara");
        inventory.add("spaghetti");
        inventory.add("palabok");
        inventory.add("pancit");
        inventory.add("lmepancit");
        inventory.add("plainrice");
        inventory.add("friedrice");
        inventory.add("boiledegg");
        inventory.add("friedegg");
        inventory.add("lumpia");
        inventory.add("shanghai");
        inventory.add("siomai");
        inventory.add("siopao");
        inventory.add("torta");
        inventory.add("ampalaya");
        inventory.add("chopsuey");
        inventory.add("monggo");

        // async refreshing
        printDashboard(); //first paint
        Thread refresher = new Thread(() -> {
            while (loggedIn) {
                if (shouldRefresh) {
                    clearTerminal();
                    printDashboard();
                }
                try {
                    for (int i = 0; i < 10 && loggedIn; i++) {
                        Thread.sleep(25);
                    }
                } catch (InterruptedException e) {
                    break;
                }
            }
        });
        refresher.start();

        //main REPL
        while (loggedIn) {
            //wait for user to interrupt live display
            scn.nextLine();
            shouldRefresh = false;
            clearTerminal();

            //display action menu
            System.out.println(Ansi.BG_BLUE + Ansi.BRIGHT_YELLOW + "LNU Cafeteria Ordering System          \n" + Ansi.RESET);
            System.out.print(
                    "Actions:\n"
                    + "  (" + Ansi.BOLD + Ansi.BG_BRIGHT_BLUE + "1" + Ansi.RESET + ") " + Ansi.BRIGHT_YELLOW + "ENTER" + Ansi.RESET + " AN ORDER\n"
                    + "  (" + Ansi.BOLD + Ansi.BG_BRIGHT_BLUE + "2" + Ansi.RESET + ") " + Ansi.BRIGHT_YELLOW + "DELETE" + Ansi.RESET + " AN ORDER\n"
                    + "  (" + Ansi.BOLD + Ansi.BG_BRIGHT_BLUE + "3" + Ansi.RESET + ") " + Ansi.BRIGHT_YELLOW + "SEE" + Ansi.RESET + " ACTIVE ORDERS\n"
                    + "  (" + Ansi.BOLD + Ansi.BG_BRIGHT_BLUE + "4" + Ansi.RESET + ") " + Ansi.BRIGHT_YELLOW + "REVIEW " + Ansi.RESET + "ORDER HISTORY\n"
                    + "  (" + Ansi.BOLD + Ansi.BG_BRIGHT_BLUE + "5" + Ansi.RESET + ") VIEW/EDIT LIST OF " + Ansi.BRIGHT_YELLOW + "ORDERABLE ITEMS" + Ansi.RESET + "\n"
                    + "  (" + Ansi.BOLD + Ansi.BG_BRIGHT_BLUE + "0" + Ansi.RESET + ") " + Ansi.BRIGHT_YELLOW + "EXIT" + Ansi.RESET + " ORDERING SYSTEM\n"
                    + "\n"
                    + "Enter an action (0–5), or leave empty and press Enter to go back:");

            //get and handle input from user
            input = scn.nextLine();
            if (!input.isBlank()) {
                String firstToken = input.split("\\s+")[0];
                switch (firstToken) {
                    case "0":
                        loggedIn = false;
                        continue;
                    case "1":
                        EnterOrder.call();
                        setTemporaryStatus("Exited 'Enter Order' menu.");
                        break;
                    case "2":
                        DeleteOrder.call();
                        break;
                    case "3":
                        ViewActiveOrders.call();
                        break;
                    case "4":
                        ViewOrderHistory.call();
                        break;
                    case "5":
                        ViewOrderableItems.call();
                        break;
                    default:
                        setTemporaryStatus("Unknown action. Please try again.");
                        break;
                }
            }
            clearTerminal();
            printDashboard();
            shouldRefresh = true;
        }
        //end of main REPL
        clearTerminal();
        System.out.println("Exited the LNU Cafeteria ordering system.");
    }

    // /////////////////////////////////////////////////////////////////////////
    public static void setTemporaryStatus(String message) {
        status = message;
        statusChangedTick = System.nanoTime();

        final long thisTick = statusChangedTick;
        new Thread(() -> {
            try {
                Thread.sleep(5000);
            } catch (InterruptedException ignored) {
            }
            // Only clear if no newer status replaced it
            if (statusChangedTick == thisTick) {
                status = "";
            }
        }).start();
    }

    public static void printDashboard() {
        System.out.println(Ansi.BG_BLUE + Ansi.BRIGHT_YELLOW + "LNU Cafeteria Ordering System          \n" + Ansi.RESET);
        System.out.println(oldestOrders());
        System.out.println();
        System.out.println(boxedStatus());
        System.out.println();
        System.out.println(Ansi.BLINK + "Press ENTER to interact." + Ansi.RESET);
        System.out.println();
    }

    public static String oldestOrders() {
        final String TITLE_BAR = "───────────────────────────── OLDEST ORDERS ────────────────────────────────────";
        final String BAR = "────────────────────────────────────────────────────────────────────────────────";
        final int WIDTH = 80;

        StringBuilder sb = new StringBuilder();

        sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.RED).append(Ansi.BOLD)
                .append(TITLE_BAR, 0, WIDTH).append("\n");

        // column headers
        sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.BLUE).append(Ansi.BOLD)
                .append(String.format("%-4s │ %-12s │ %-3s │ %-9s", "No.", "Item", "To", "Time since order                                    "))
                .append(Ansi.RESET).append("\n");

        synchronized (activeOrders) {
            int count = Math.min(8, activeOrders.size());
            for (int i = 0; i < count; i++) {
                Order o = activeOrders.get(i);

                long elapsedMillis = System.currentTimeMillis() - o.timeCreated;
                long minutes = elapsedMillis / 60000;
                long seconds = (elapsedMillis / 1000) % 60;

                // truncate strings if needed
                String item = o.itemId.length() > 12 ? o.itemId.substring(0, 12) : o.itemId;
                String recipient = o.recipientDisplay.length() > 3 ? o.recipientDisplay.substring(0, 3) : o.recipientDisplay;

                String line = String.format("%-4d │ %-12s │ %-3s │ %2d:%02d",
                        i + 1, item, recipient, minutes, seconds);

                // pad to full width for box alignment
                if (line.length() < WIDTH) {
                    line += " ".repeat(WIDTH - line.length());
                }

                sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.BLUE).append(Ansi.BOLD)
                        .append(line).append(Ansi.RESET).append("\n");
            }

            // fill empty rows if fewer than 8 orders
            for (int i = count; i < 8; i++) {
                String emptyLine = " ".repeat(WIDTH);
                sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.BLUE).append(Ansi.BOLD)
                        .append(emptyLine).append(Ansi.RESET).append("\n");
            }
        }

        sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.RED).append(Ansi.BOLD)
                .append(BAR, 0, WIDTH).append(Ansi.RESET);

        return sb.toString();
    }

    public static String boxedStatus() {
        final String TITLE_BAR = "──────────────────────────────── STATUS ────────────────────────────────────────";
        final String BAR = "────────────────────────────────────────────────────────────────────────────────";
        final int WIDTH = 80;
        StringBuilder sb = new StringBuilder();

        // top bar
        sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.RED).append(Ansi.BOLD)
                .append(TITLE_BAR, 0, WIDTH).append("\n");

        // status line
        String statusLine = String.format("  %-78s", status);
        sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.MAGENTA).append(Ansi.BOLD)
                .append(statusLine).append(Ansi.RESET).append("\n");

        // current time line
        String currentTime = ZonedDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss z"));
        String timeLine = String.format("  Current time: %-64s", currentTime);
        sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.BLUE).append(Ansi.BOLD)
                .append(timeLine).append(Ansi.RESET).append("\n");

        // orders line
        String ordersLine = String.format(" %d active orders.", activeOrders.size());
        ordersLine = String.format(" %-79s", ordersLine);
        sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.BLUE).append(Ansi.BOLD)
                .append(ordersLine).append(Ansi.RESET).append("\n");

        // bottom bar
        sb.append(Ansi.BG_BRIGHT_YELLOW).append(Ansi.RED).append(Ansi.BOLD)
                .append(BAR, 0, WIDTH).append(Ansi.RESET);

        return sb.toString();
    }

    public static void clearTerminal() {
        try {
            if (System.getProperty("os.name").startsWith("Windows")) {
                new ProcessBuilder("cmd", "/c", "cls")
                        .inheritIO()
                        .start()
                        .waitFor();
            } else {
                new ProcessBuilder("clear") //for UNIX and UNIX-like OSes
                        .redirectError(ProcessBuilder.Redirect.DISCARD)
                        .inheritIO()
                        .start()
                        .waitFor();
            }
        } catch (IOException | InterruptedException ignored) {
        }
    }
}

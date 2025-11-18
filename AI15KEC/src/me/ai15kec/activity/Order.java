package me.ai15kec.activity;

public class Order {
    public final String itemId;
    public final int amount;
    public final long timeCreated;
    public final String recipient; //delivery referral # or table #
    public final String recipientDisplay;

    public Order(String itemId, int amount, String recipient) {
        this.itemId = itemId;
        this.amount = amount;
        this.recipient = recipient;
        this.timeCreated = System.currentTimeMillis();
        if (recipient.matches("\\d{1,3}")) { //integer, no longer than 3 digits
            this.recipientDisplay = recipient;
        } else {
            this.recipientDisplay = "SEE";
        }
    }
}

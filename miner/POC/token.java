import java.util.*;

/*
-Burn the tokens
-Calculate the gap
-find how many % of the gap is now owned by the user
-add the % of the gap to user's total

-if user wants to mint their tokens, they do so by applying the percentage to a current gap
-they can get a full refund if the currentSupply+refund is <=21000000, as a consequence, we are mining new tokens.
-if currentSupply+refund > 21000000, the refund gets the total % applied to a gap.
 */
public class mainRun {

 public static final token token = new token();
 public static final double totalTokens = 21000000;
 public static double totalBurned = 0;

//burns = address->totalBurned
//miningPower = address->totalMiningPower
private static final Map<String, Double> burns = new HashMap<>();
private static final Map<String, Double> miningPower = new HashMap<>();


//THE MAIN IS FOR TESTING PURPOSES ONLY!!!
 public static void main(String[] args){

//     token.mint("a",10000);
//     token.mint("b",100);
//
//     System.out.println("a balance: "+token.getBalance("a"));
//     System.out.println("b balance: "+token.getBalance("b"));
//     System.out.println("supply: "+token.getCurrentSupply());
//
//     System.out.println("b balance: "+token.getBalance("b")+"\tpower:"+miningPower.get("b"));
//
//
//     mine("a",1000);
//
//     reward("b");
//
//     System.out.println("a balance: "+token.getBalance("a"));
//     System.out.println("b balance: "+token.getBalance("b"));
//     System.out.println("supply: "+token.getCurrentSupply());

     //distribute tokens to random addresses
     Random rnd = new Random();
     double distribute = 1000000;
     List<String> addresses = new ArrayList<>();

     while(distribute>0){
         double amt = (double) rnd.nextInt(10000)+rnd.nextDouble();
         String address = UUID.randomUUID().toString();
         distribute = distribute-amt;
         token.mint(address,amt);
         addresses.add(address);
     }

     double mem = 0;
     long cnt = 0l;
     while(true){
         if(mem!=getCurrentSupply()){
             mem = getCurrentSupply();
             if(cnt%1000000==0) {
                 System.out.println(cnt + "\t" + token.getCurrentSupply()+"\t"+token.getMaximum());
             }
            cnt++;
         }
         if(rnd.nextBoolean()){
             //transfer
             rndTransfer(rnd, addresses);
         }
         if(rnd.nextInt(2)==0){
             //addAddress
             if(addresses.size()<10000) {
                 addNewAddress(addresses);
             }
         }
         if(rnd.nextInt(2)==0){
             //mine
             runMiner(rnd, addresses);
         }
         if(rnd.nextInt(2)==0){
             //reward
             String rndAddr = addresses.get(rnd.nextInt(addresses.size()));
             reward(rndAddr);
         }
     }

 }
    //---THE CODE BELOW IS NOT THE MINER!----------
    private static void runMiner(Random rnd, List<String> addresses) {
        String rndAddr = addresses.get(rnd.nextInt(addresses.size()));
        double amt = token.getBalance(rndAddr);
        if(amt>0) {
            double mineAmt;
            if(amt<1){
                mineAmt =  rnd.nextDouble();
                while (mineAmt > amt) {
                    mineAmt =  rnd.nextDouble();
                }
            }
            else{
                mineAmt = (double) rnd.nextInt((int) Math.abs(amt)) + rnd.nextDouble();
                while (mineAmt > amt) {
                    mineAmt = (double) rnd.nextInt((int) Math.abs(amt)) + rnd.nextDouble();
                }
            }

            mine(rndAddr,mineAmt);
        }
    }

    private static void addNewAddress(List<String> addresses) {
        String newAddress = UUID.randomUUID().toString();
        token.addAddress(newAddress);
        addresses.add(newAddress);
    }

    private static void rndTransfer(Random rnd, List<String> addresses) {
        String from = addresses.get(rnd.nextInt(addresses.size()));
        String to = addresses.get(rnd.nextInt(addresses.size()));
        double fromAmt = token.getBalance(from);
        if(fromAmt>0){

            double transferAmt;
            if(fromAmt<1){
                transferAmt =  fromAmt;
                while (transferAmt > fromAmt) {
                    transferAmt =  rnd.nextDouble();
                }
            }
            else {
                transferAmt = (double) rnd.nextInt((int) Math.abs(fromAmt)) + rnd.nextDouble();
                while (transferAmt > fromAmt) {
                    transferAmt = (double) rnd.nextInt((int) Math.abs(fromAmt)) + rnd.nextDouble();
                }
            }
            token.transfer(from,to,transferAmt);
        }
    }




    //-------------MINER IS BELOW------------------
    public static void reward(String address){
        if(burns.get(address)==null) return;
        if(burns.get(address)==0) return;

        double gap = getGapSize();
        double purchasePower = miningPower.get(address);
        double reward = gap*purchasePower;
        double burned = burns.get(address);
        if(reward<burned && getCurrentSupply()+reward<=totalTokens){reward = burned;}
        else if(getCurrentSupply()+reward>totalTokens){reward=totalTokens-getCurrentSupply();}
        mint(address,reward);
        totalBurned = totalBurned-burned;
        burns.put(address,0.0);
        miningPower.put(address,0.0);
    }

    public static void mine(String address, double amount){ //address is always the msg.sender!

        if(token.getBalance(address)<amount) return;


        token.burn(address,amount);
        totalBurned = totalBurned+amount;
        double userMiningPower = getPurchasePower(amount);

        //is simpler in solidity
        if(burns.get(address)==null){
            burns.put(address, amount);
        }
        else{
            double burnedPerUser = burns.get(address);
            burnedPerUser = burnedPerUser+amount;
            burns.put(address,burnedPerUser);
        }

        //is simpler in solidity
        if(miningPower.get(address)==null){
            miningPower.put(address, userMiningPower);
        }
        else{
            double totalUserMiningPower = miningPower.get(address);
            totalUserMiningPower = totalUserMiningPower+userMiningPower;
            miningPower.put(address,totalUserMiningPower);
        }

    }



    public static double getPurchasePower(double amount){
        return amount/getGapSize();
    }

    public static void mint(String address, double amount){ //calls the router contract
        token.mint(address,amount);
    }

    public static void burn(String address, double amount){ //calls the router contract
        if(amount> token.getCurrentSupply()) return;
        if(token.getBalance(address)<amount) return;
        token.burn(address, amount);
    }

    public static double getCurrentSupply(){
        return token.getCurrentSupply();
    }

    public static double getGapSize(){
        return 21000000-token.getCurrentSupply();
    }


}

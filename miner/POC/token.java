import java.util.HashMap;
import java.util.Map;

public class token {

    public double currentSupply = 0;

    public final Map<String, Double> balances = new HashMap<>();

    public double getMaximum(){
        double ret = 0;
        for(String key:balances.keySet()){
            if(ret<balances.get(key)){
                ret = balances.get(key);
            }
        }
        return ret;
    }


    public double getBalance(String address){
        if(balances.get(address)==null) return 0.0;
        return balances.get(address);
    }

    public int getAddressesSize(){
        return balances.size();
    }

    public double getCurrentSupply() {
        return currentSupply;
    }

    public void setCurrentSupply(double currentSupply) {
        this.currentSupply = currentSupply;
    }

    public void burn(String address, double amount) {
        currentSupply = currentSupply - amount;
        balances.put(address, balances.get(address)-amount);
    }

    public void mint(String address, double amount) {
        currentSupply = currentSupply+amount;
        balances.put(address,getBalance(address)+amount);
    }

    public boolean addressExists(String address){
        return balances.containsKey(address);
    }

    public void addAddress(String address){
        if(!addressExists(address)) balances.put(address,0.0);
    }

    public void transfer(String from, String to, double amount){
        if(getBalance(from)<amount) return;
        balances.put(from,getBalance(from)-amount);
        balances.put(to,getBalance(to)+amount);
    }


}

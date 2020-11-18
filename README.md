# Good-distribution-model-and-simulation-in-Netlogo


In this project, a system of goods distribution was designed, modeled,  and simulated using NetLogo, an ABM modeling environment. Agent-based modeling, or ABM, is a computational modeling methodology that focuses on the individual active components of a system and simulates actions and interactions.
The system studied and modeled in the report constitutes the physical distribution from the warehouse or central distribution center to the retailers. The modeling process followed real actions, rules, and constraints that actually occur in real life with some assumptions and exceptions. Also, this model allows users inputs and also displays their outputs for simulation purposes.


The link of model: file:///D:/IT%20learning/Portfolios/Good-distribution-model-and-simulation-in-Netlogo/ABMModel.html




![alt text](https://github.com/danayagrad/Good-distribution-model-and-simulation-in-Netlogo/blob/main/GoodDistribution.jpg)




1. Tools: NetLogo

2. Model scope:
	- The model covers only one branch of the downstream supply chain process, from one warehouse to one distribution 		hub and then on to retailers.
	- For this model, stock at the warehouse is assumed to always be sufficient for delivery. 
	- Another assumption is that retailers were considered as a group in the nearby area. Distance between them isn’t 		considered. The demand that occurs is the collective demand of the whole group.

3. Model concepts:
	- 2 components in the system: warehouse and distribution hub.
	- Warehouse is the main actor in this model. It decides to deliver the goods between 2 route options for shipping, 	either via a hub, or direct delivery to the customer.
	- The decision rules are to choose the cheapest cost route first if the capacity of the route is available.
	- The warehouse can’t deliver more than its maximum capacity. One order ship to a hub, taking one capacity, while 		one order delivers directly to the retailer and takes 2 capacities.
	- For every delivered order, cost incurs. It is assumed that the cost via the hub route is cheaper, as the 	distance it runs on an empty truck from the retailers back to the hub is shorter than from the retailers to the 	warehouse. 		
	- Moreover, to mimic reality, it is also assumed that any delivery that has orders less than 80% of max capacity 		costs 20% more than delivery with a full, or more than 80% of max, capacity. However, the cost parameters used in 		this model aren't real data.
	- Any order that is not delivered within 2 days from the day demand is generated, is considered a late delivery 		order.
	- The hub can’t make decisions, it receives orders for delivery and then delivers them to the retailers. It can’t 		receive orders more than its max capacity.
	- The hub can’t deliver more than its maximum capacity. One order shipped to a retailer deducts one delivery 		capacity.

4. User inputs:
	- Demand: the user can input based on daily demand of orders to be delivered to the retailer.
	- Demand factor range: a range of random numbers which will be added up based on demand to create some uncertainty 	in the total demanded orders for each day. 
	- Hub maximum delivery capacity per day: the maximum capacity that a hub can deliver. The capacity number is  			incremented by 30 to mimic truck size used in reality that is usually smaller when delivery from hub to retailers.
	- Warehouse maximum delivery capacity: the maximum capacity that the warehouse can deliver. The capacity number is  	incremented by 50 to mimic truck size used in reality that is usually bigger when delivery from central warehouse 		to distribution hub.


5. Outputs:
	- Total order: accumulated total orders from the beginning to until the current tick.
	- Late delivery: accumulated late orders which aren’t delivered within 2 days. 
	- Total cost: accumulated total delivery cost from the beginning to until the current tick.
	- Average total cost per order: total cost divided by total orders, excluding backlog.
	- Backlog: Total undelivered orders at the current tick.

6. Example: 
An example was simulated to show the result of model. The scenerio was when delivery capacity of the warehouse and delivery capacity of the hub is less than total demand level. In this example, based-demand was 120, demand factor range was 20, delivery capacity of the warehouse was 100, and delivery capacity of the hub was 100. The results averaged from 10 runs are: average delivery cost per order was 1.8, total number of orders was 3877, late delivery per month was 777. The comparison of total order and late order is shown in the figure below.


![alt text](https://github.com/danayagrad/Good-distribution-model-and-simulation-in-Netlogo/blob/main/Example.jpg)


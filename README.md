# MovieSearch
## Intro
Introducing MoveSearch, discovering and exploring movies! With MoveSearch, you can easily search for popular movies. This app fetches the popular movie data from TMDB sources, providing you with accurate and up-to-date information. 


## Architecture
Architecture comprises three key components: the Database Data Provider, the Web Data Provider, and the Service layer. The Database Data Provider interacts directly with our local database, efficiently managing local data storage and retrieval. Meanwhile, the Web Data Provider interfaces with external web services, handling data fetching and synchronization with remote servers.
Central to our architecture is the Service layer, which serves as the orchestrator of data operations. It encapsulates both the Database and Web Data Providers, providing a unified interface for the ViewModel layer to interact with. This abstraction shields the ViewModel from the complexities of data management, promoting modularity and ease of testing.

Connecting it all together is the ViewModel layer, responsible for mediating between the Service layer and the View. Through reactive bindings and data transformation, the ViewModel fetches data from the Service layer and prepares it for presentation in the View.

![Screenshot 2024-04-09 at 8 45 50 pm](https://github.com/GRGBISHOW/MovieSearch/assets/20558114/015463d7-b33f-4aab-a942-df1eeeeb7a9d)


## Installation
This project only has two SPM package dependencies which are also written by myself. I mostly use theom to construct POC for ideas. Please feel free to have a look. 

[Minimal Networking](https://github.com/GRGBISHOW/MinimalNetworking)

[Design System](https://github.com/GRGBISHOW/DesignSystem)


Just download the project and let the packages get resolved. And It's ready to build.

## Features Implemented
* Popular Movie listing with Pagination
* Search
* Details View
* Offline Mode (Shows last Fetched data)
* Online/Offline Indicator
* UI supports both dark and light mode
* Image Caching
* Unit tests


## Demo

![demo_1](https://github.com/GRGBISHOW/MovieSearch/assets/20558114/d646603d-47de-4431-92ff-39a30eda07c6)

## Coverage
I have added the coverage report which provides valuable insights into the quality and effectiveness of our test suite. By analyzing the coverage report, we can assess which parts of our codebase are adequately tested and identify areas that may require additional testing. I havenot added UITests as you can see coverage are low for UI files.

![Screenshot 2024-04-09 at 9 02 13 pm](https://github.com/GRGBISHOW/MovieSearch/assets/20558114/8619eb78-b550-46db-8886-257ef8a55b7f)


## Future:
* Favorite List
* Search via API
* UI Tests
* Localize Strings


## App Behaviour
* Fetches list for popular movies saves into local database and allow pagination
* Can view details by clicking on each item
* Search results are based on local database
* In Offline Mode it show last fetched datas






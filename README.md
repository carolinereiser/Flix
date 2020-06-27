# Project 2 - Flix

Flix is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: 18-20 hours spent in total

## User Stories

The following **required** functionality is complete:

- User sees an app icon on the home screen and a styled launch screen.
- User can view a list of movies currently playing in theaters from The Movie Database.
- Poster images are loaded using the UIImageView category in the AFNetworking library.
- User sees a loading state while waiting for the movies API.
- User can pull to refresh the movie list.
- User sees an error message when there's a networking error.
- User can tap a tab bar button to view a grid layout of Movie Posters using a CollectionView.

The following **optional** features are implemented:

- User can tap a poster in the collection view to see a detail screen of that movie
- User can search for a movie.
- All images fade in as they are loading.
- Customize the navigation bar.
- Customize the UI.

The following **additional** features are implemented:

- User can select the backdrop poster in the details screen and view the movie trailer
- User can select the type of movies they want to see on the grid view (Superhero, Young Adult, Disney, Sci-Fi, and War)

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. How to better implement the scroll view so the user doesn't have to hold down the screen the whole time while scrolling
2. Further discuss the reason the table view and collection view cells show up when we call the API

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<blockquote class="imgur-embed-pub" lang="en" data-id="a/2s1BLen" data-context="false" ><a href="//imgur.com/a/2s1BLen"></a></blockquote>

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

I struggled a bit with implementing the search bar and it took me almost 3 hours to figure it out, in the future I will ask for help earlier so I don't run into such a road block. I also wanted to implement a recommendations link for the details page. The API call was working but the cells weren't appearing on the collection view. If I had more time with this project, I would figure out how to implement the recommendations page.

## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library

## License

    Copyright 2020 Caroline Reiser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

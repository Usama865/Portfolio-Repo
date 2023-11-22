import streamlit as st
from Helper_file import new_movies
from Helper_file import recommend
import numpy as np
import requests as rq
import json 



title=st.title("Movie Recommendation System")

def movie_poster(movie_id: int):
    response= rq.get("https://api.themoviedb.org/3/movie/{}?api_key=ddf1b64692217b6f9abb5a88eab481a1&language=en-US".format(movie_id))
    poster_data= response.json()
    url="http://image.tmdb.org/t/p/w500" + poster_data['poster_path'] 
    return url


select_bar=st.selectbox("Enter Movie Name Here:",new_movies["title"])
result=recommend(select_bar)[0]

# for poster 
poster_result=[]
for i in recommend(select_bar)[1]:
    poster_result.append(movie_poster(i))

## Button Logic
if st.button("Get Recommendations"):
    num_columns = 4
    num_rows = len(result) // num_columns + (len(result) % num_columns > 0)  # Calculate the number of rows

    for row in range(num_rows):
        col = st.columns(num_columns)

        for col_index in range(num_columns):
            element_index = row * num_columns + col_index
            if element_index < len(result):
                with col[col_index]:
                    st.subheader(result[element_index], divider='grey')
                    st.image(poster_result[element_index])

        # st.image("https://static.streamlit.io/examples/cat.jpg")
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    # st.write(result,poster_result)
    # st.write(movie_poster(poster_result)[0])  

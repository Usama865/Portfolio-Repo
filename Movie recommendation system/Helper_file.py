import numpy as np
import pandas as pd
import ast
import nltk
from nltk.stem.porter import PorterStemmer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity


ps= PorterStemmer()
credits = pd.read_csv("tmdb_5000_credits.csv")
movies = pd. read_csv("tmdb_5000_movies.csv")
movies= movies.merge(credits,on='title')
movies=movies[["genres","id","keywords","overview","title","cast","crew","production_companies"]]
movies.dropna(inplace=True)

def convert(obj):
    L=[]
    for i in ast.literal_eval(obj):
        L.append(i["name"])
    return L
def convert1(obj):
    L=[]
    for i in ast.literal_eval(obj):
        L.append(i["name"])
    return L
def convert2(obj):
    L=[]
    for i in ast.literal_eval(obj):
        L.append(i["name"])
    return L
def fetch_director(obj):
    L=[]
    for i in ast.literal_eval(obj):
        if i["job"] == "Director" :
            L.append(i["name"])
            break
    return L

def fetch_actor(obj):
    L=[]
    counter=0
    for i in ast.literal_eval(obj):
        if counter !=3:
            L.append(i["name"])
            counter+=1
        else:
            break
    return L


movies["genres"]=movies["genres"].apply(convert)
movies["keywords"]=movies["keywords"].apply(convert1)
movies["production_companies"]=movies["production_companies"].apply(convert2)
movies["crew"]=movies["crew"].apply(fetch_director)
movies["cast"]=movies["cast"].apply(fetch_actor)


movies['overview']=movies['overview'].apply(lambda x:x.split())

columns_to_clean = ["genres", "keywords", "cast", "crew", "production_companies"]

for column in columns_to_clean:
    movies[column] = movies[column].apply(lambda x: [i.replace(" ", "") for i in x])

movies["tags"]=movies["overview"]+movies["genres"]+movies["keywords"]+movies["cast"]+movies["crew"]+movies["production_companies"]
movies= movies[["id","title","tags"]]
movies["tags"]=movies["tags"].apply(lambda x:" ".join(x))
movies["tags"]=movies["tags"].apply(lambda x:x.lower())

def stem(text):
    y=[]
    for i in text.split():
        y.append(ps.stem(i))
    return " ".join(y)
movies['tags'] = movies['tags'].apply(stem)

new_movies= movies


vectorizer=TfidfVectorizer(stop_words='english',max_features=3000)
vector_matrix=vectorizer.fit_transform(new_movies['tags']).toarray()
similarity = cosine_similarity(vector_matrix)

def recommend(movie):
    movie_index=movies[movies['title']== movie].index[0]
    distance = similarity[movie_index]
    recommended_movies_list_tuple=sorted(list(enumerate(distance)),reverse=True,key=lambda x:x[1])[1:5]
    result=[]
    movie_poster_id=[]
    for i in recommended_movies_list_tuple:
        result.append(movies.iloc[i[0]].title)
        movie_poster_id.append(movies.iloc[i[0]].id)

    return result,movie_poster_id


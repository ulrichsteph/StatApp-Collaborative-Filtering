# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# ENSAE - 2AD - Groupe de statistique appliquee
#    Sujet : Filtrage collaborative
#       Encadrants : Vincent Cottet et Mehdi Sebbar
#       Etudiants : Biwei Cui, Claudia Delgado, Mehdi Miah et Ulrich Mpeli Mpeli
#
#       Fichier : analysis.R
#       Description : analyses descriptives sur la base des notes, des utilisateurs et des films
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# ===================================== 1.PREAMBULE ===============================================

## Clean up
rm(list=ls()) 
cat("\014") 

## Set working
#getwd() 
#setwd("C:/Users/Maestro/Desktop/2A/Stat_App/Donnees") # Changer le repertoire de travail
#setwd("~/ENSAE/2AD/Stat-App/Collaborative_Filtering_Project/Codes/Descriptive_analysis")

# ================================== 2.OUVERTURE DES FICHIERS =======================================

## Lecture du fichier des notes

data.Ratings = read.table(file=file.choose(),header=F,colClasses = c(V4 = "NULL"))
#data.Ratings = read.csv("../../Data/ml-100k/u.data.", header = FALSE, sep='\t')
colnames(data.Ratings) = c("userID", "movieID", "rating","timestamp")
data.Ratings$timestamp = NULL

## Lecture du fichier des utilisateurs

#data.Users = read.table(file=file.choose(),header=F, sep='|', stringsAsFactors = TRUE)
data.Users = read.csv("../../Data/ml-100k/u.user", header = FALSE, sep='|', stringsAsFactors = TRUE)
colnames(data.Users) = c("userID", "age", "gender", "occupation", "zip.code")

## Lecture du fichier des films

#data.Movies = read.table(file=file.choose(),header=F,sep="|", quote = "\"",colClasses = c(V4 = "NULL"))
data.Movies = read.csv("../../Data/ml-100k/u.item", header = FALSE, sep='|')
data.Movies[4] = NULL
vect.MovieGenres = c("unknown", "action", "adventure", "animation", "children's", "comedy", 
                     "crime", "documentary", "drama", "fantasy", "film-noir", "horror", 
                     "musical", "mystery", "romance", "sci-fi", "thriller", "war", "western")

#MG=read.table(file=file.choose(),header=F,sep="|", quote = "\"") ##choisir u.genre
#MG=MG$V1
#nbG=length(MG)

nb.Genres = length(vect.MovieGenres)
colnames(data.Movies) = c("movieID", "title", "date", "IMDbURL", vect.MovieGenres)
#colnames(data.Movies)=c("movieID", "title", "date", "IMDbURL", MG) Ã  modifier de tel sorte que MG soit une string


# ======================== 3.DETERMINATION DU VOLUME DE DONNEES DES BASES (controles) ============================

#3.1# A PARTIR DE LA BASE DES NOTES

## Nombre de notes

nb.Ratings = dim(data.Ratings)[1]
cat("La base de donnees contient exactement", nb.Ratings, "notes.")

## Nombre d'utilisateurs uniques

nb.Users = length(unique(data.Ratings$userID))
cat("La base de donnees contient exactement", nb.Users, "utilisateurs uniques.")

## Nombre de films uniques

nb.Movies = length(unique(data.Ratings$movieID))
cat("La base de donnees contient exactement", nb.Movies, "films uniques.")

#3.2# VERIFICATION AVEC LA BASE DES UTILISATEURS

## Nombre d'utilisateurs

if(nb.Users == dim(data.Users)[1]){
  cat("La base de donnÃ©es contient bien", nb.Users, "utilisateurs.")
} else{
  cat("Attention : il y a un conflit sur le nombre d'utilisateurs.")
  break
}

#3.3# VERIFICATION AVEC LA BASE DES FILMS

## Nombre de films

if (nb.Movies == dim(data.Movies)[1]){
  cat("La base de donnees contient bien", nb.Movies, "films.")
} else{
  cat("Attention : il y a un conflit sur le nombre de films.")
  break
}

# ====================================== 4.STATISTIQUE D'ORDRE 1 =========================================

#4.1# SUR LES NOTES

## Statistiques des notes

cat("La moyenne des", nb.Ratings, "notes est de", round(mean(data.Ratings$rating),2), "; l'ecart-type est de", round(sd(data.Ratings$rating),2), ".")
boxplot(data.Ratings$rating, main = "Notes discretes attribuÃ©es aux films") #TO DO : remplacer par un diagramme en bÃ¢ton
#need histogramme

#4.2# SUR LES UTILISATEURS

## Age

cat("La moyenne des ages est", round(mean(data.Users$age),2), "ans avec un ecart-type de", round(sd(data.Users$age),2), "ans.")
# histogramme des ages

## Proportion homme/femme

nb.Men = sum(data.Users$gender == "M")
nb.Women = sum(data.Users$gender == "F")
cat("La base de donnees est composee de", nb.Men, "hommes, soit", round(100*nb.Men/nb.Users,2), 
    "% et", nb.Women, "femmes, soit" ,round(100*nb.Women/nb.Users,2),"% .")

## Proportions dans les metiers

as.data.frame(summary(data.Users$occupation))
#remarque : ces catÃ©gories professionnelles sont etranges : ce n'est pas une categorisation CSP traditionnelle.
## Proportions dans les codes postales

as.data.frame(summary(data.Users$zip.code))
#remarque : le code postal n'est pas du tout pertinent (699 other)

#4.3# SUR LES FILMS

## Repartition par genres de films

vect.nb.MoviesPerGenre = as.matrix(apply(data.Movies[5:23],2, sum, na.rm = TRUE))
boxplot(vect.nb.MoviesPerGenre, main = "nombre de films par genre")
#need diagramme en baton

# ==================================== 5.STATISTIQUE D'ORDRE 2 =========================================

#5.1# LIEN ENTRE NOMBRE DE FILMS ET UTILISATEURS

## Repartition du nombre de films notes par utilisateur

vect.nb.RatingsPerUser = as.data.frame(cbind(seq(1,nb.Users), tabulate(bin=data.Ratings$userID, nbins = nb.Users))) 
colnames(vect.nb.RatingsPerUser) = c("userID", "nb.Ratings")

## Statistiques sur le nombre de films notees par utilisateur

summary(vect.nb.RatingsPerUser$nb.Ratings)
boxplot(vect.nb.RatingsPerUser$nb.Ratings, main = "Nombre de films notes par utilisateur")
#need diagramme en baton

#5.2# LIEN ENTRE MOYENNE DES NOTES ET UTILISATEUR

stat.RatingsPerUser = matrix(0, nrow = nb.Users, ncol = 6) # matrice comprenant l'ID de l'utilisateur 
#                    la moyenne des notes
#                    l'Ã©cart-type des notes
#                    la note maximale 
#                    la note maximale 
#                    la mediane des notes

colnames(stat.RatingsPerUser) = c("userID", "mean", "sd", "max", "min", "med")
for (user in 1:nb.Users) { 
  x=data.Ratings$rating[data.Ratings$userID == user] # x : ensemble des notes pour l'utilisateur user
  stat.RatingsPerUser[user,] = c(user,round(mean(x),2),round(sd(x),2),max(x),min(x),median(x))
}
rm(x)

## Tableau rÃ©capitulatif
recap.Users = merge(vect.nb.RatingsPerUser, stat.RatingsPerUser, by.x = "userID", by.y = "userID")
recap.Users = merge(recap.Users, data.Users, by.x = "userID", by.y = "userID")
rm(vect.nb.RatingsPerUser)
rm(stat.RatingsPerUser)

## Statistiques sur les notes moyennes donnÃ©es par utilisateur

summary(recap.Users$mean)
boxplot(recap.Users$mean, main = "Note moyenne donnÃ©e par utilisateur")

#5.3# LIEN ENTRE NOMBRE DE NOTES ET FILM

## RÃ©partition du nombre de notes par film

vect.nb.RatingsPerMovie = as.data.frame(cbind(seq(1,nb.Movies), tabulate(bin=data.Ratings$movieID, nbins = nb.Movies))) 
colnames(vect.nb.RatingsPerMovie) = c("movieID", "nb.Ratings")

## Statistiques sur le nombre de notes par films

summary(vect.nb.RatingsPerMovie$nb.Ratings)
boxplot(vect.nb.RatingsPerMovie$nb.Ratings, main = "Nombre de notes par film")

#5.4# LIEN ENTRE MOYENNE DES NOTES ET FILM

## Note moyenne par film / Ecart-type des notes par film
## Note maximale par film / Note minimale par film / Note mÃ©diane par film
####### POUR NE PAS FAIRE TOURNER LA MEME BOUCLE DEUX FOIS

stat.RatingsPerMovie = matrix(0, nrow = nb.Movies, ncol = 6) # matrice comprenant l'ID du film 
#                    la moyenne des notes
#                    l'Ã©cart-type des notes
#                    la note maximale 
#                    la note maximale 
#                    la mediane des notes
colnames(stat.RatingsPerMovie) = c("movieID", "mean", "sd", "max", "min", "med")

for (movie in 1:nb.Movies) { 
  x=data.Ratings$rating[data.Ratings$movieID == movie] #x : ensemble des notes du film movie
  stat.RatingsPerMovie[movie,] = c(movie,round(mean(x),2),round(sd(x),2),max(x),min(x),median(x))
}
rm(x)

stat.RatingsPerMovie = as.data.frame(stat.RatingsPerMovie)

## Tableau rÃ©capitulatif
recap.Movies = merge(vect.nb.RatingsPerMovie, stat.RatingsPerMovie, by.x = "movieID", by.y = "movieID")
recap.Movies = merge(recap.Movies, data.Movies, by.x = "movieID", by.y = "movieID")
rm(vect.nb.RatingsPerMovie)
rm(stat.RatingsPerMovie)

## Statistiques sur les notes moyennes reÃ§ues par film

summary(recap.Movies$mean)
boxplot(recap.Movies$mean, main = "Note moyenne des films")

## Nombre d'hommes et de femmes ayant vu un film donnÃ© (ainsi que la moyenne des notes attribuÃ©es)

RatingPerMoviePerGender = matrix(0, nrow = nb.Movies, ncol = 5) #matrice comprenant l'ID du film 
MoyWomen=matrix(0, nrow = nb.Movies, ncol = 2) 
cond2=(data.Users$gender[data.Ratings$userID]=="M")
for (movie in 1:nb.Movies) { 
  cond1=data.Ratings$movieID == movie
  x=data.Ratings$rating[cond1&cond2]
  y=data.Ratings$rating[cond1&!(cond2)]
  RatingPerMoviePerGender[movie,] = c(movie,length(x),round(mean(x),2),length(y),round(mean(y),2))
  MoyWomen[movie,]=c(movie,(mean(data.Ratings$movieID == movie)-mean(x)*(length(x)/(length(x)+length(y))))*((length(x)+length(y))/length(y)))
}

RatingPerMoviePerGender = as.data.frame(RatingPerMoviePerGender)
colnames(RatingPerMoviePerGender ) = c("movieID", "nbMen","avgRatingMen","nbWomen","avgRatingWomen")

# on verifie que moyeWomen[i,2]=RatingPerMOviePerGender$avrRatingWomen[i] pour tout i

# ====================== 6.CORRELATION ENTRE LES FILMS ET LES UTILISATEURS ===============================

## CorrÃ©lation entre note des films et nombre de visionnage de ce film (normalement oui, et positive)

plot(recap.Movies$nb.Ratings, recap.Movies$mean, 
     main = "Lien entre nombre de visionnage et note moyenne par film", 
     xlab = "nombre de visionnage", 
     ylab = "note moyenne")

## CorrÃ©lation entre note attribuÃ©e et nombre de films vus (pas nÃ©cessairement sauf les rageux et les floodeurs)
#recap.Users = merge(vect.nb.RatingsPerUser,AvgRatingPerUser, by.x = "userID", bu.y = "userID")
plot(recap.Users$nb.Ratings, recap.Users$mean, 
     main = "Lien entre nombre de films notÃ©s et note moyenne par utilisateur", 
     xlab = "nombre de films notes", 
     ylab = "note moyenne")

# ===================================== 7.STATISTIQUE D'ORDRE ===========================================

#7.1# SUR LES FILMS (PAR RAPPORT AUX NOMBRE DE NOTES)

## Films les plus notÃ©s

nb.MostRatedMovies = 25
order.MostRatedMovies = order(recap.Movies$nb.Ratings, decreasing =TRUE)
cat("Les", nb.MostRatedMovies, "films ayant recu le plus de notes : ")
for (movie in 1:nb.MostRatedMovies){
  id.order = order.MostRatedMovies[movie]
  cat("Le film d'ID", recap.Movies$movieID[id.order], ",", 
      as.character(data.Movies$title[id.order]), ", a recu", 
      recap.Movies$nb.Ratings[id.order], "notes.")
  cat("\n")
}

## Films les moins notÃ©s

nb.LessRatedMovies = 12
order.LessRatedMovies = order(recap.Movies$nb.Ratings, decreasing =FALSE)
cat("Les", nb.LessRatedMovies, "films ayant recus le moins de notes : ")
for (movie in 1:nb.LessRatedMovies){
  id.order = order.LessRatedMovies[movie]
  cat("Le film d'ID", recap.Movies$movieID[id.order], ",", 
      as.character(data.Movies$title[id.order]), "a reÃ§u", 
      recap.Movies$nb.Ratings[id.order], "note(s).")
  cat("\n")
}

## Films n'ayant reÃ§u qu'une seule note

cat("Il y a", sum(recap.Movies$nb.Ratings == 1), "films qui n'ont reÃ§u qu'une seule note.")

## Films ayant reÃ§u moins de xxx votes

nbLimit.RatingsForMovie = 10
cat("Il y a", sum(recap.Movies$nb.Ratings <= nbLimit.RatingsForMovie), "films qui ont reÃ§u moins de", 
    nbLimit.RatingsForMovie, "votes.")

#7.2# SUR LES FILMS (PAR RAPPORT A LA MOYENNE DES NOTES)

## Films ayant les meilleurs notes

nb.BestMovies = 25
order.BestMovies = order(recap.Movies$mean, decreasing = TRUE)
cat("Les", nb.BestMovies, "meilleurs films : ")
for (movie in 1:nb.BestMovies){
  id.order = order.BestMovies[movie]
  cat("Le film d'ID", recap.Movies$movieID[id.order], ",", 
      as.character(data.Movies$title[id.order]),
      "a une note moyenne de", recap.Movies$mean[id.order], "sur",
      recap.Movies$nb.Ratings[id.order], "vote(s).")
  cat("\n")
}

## Nombre de films ayant une note moyenne de 5

cat("Il y a", sum(recap.Movies$mean == 5), "films qui ont reÃ§u une note moyenne de 5.")

## Films ayant les meilleurs notes et dÃ©passant un seuil de visionnage

cat("Les", nb.BestMovies, "meilleurs films ayant reÃ§u plus de", nbLimit.RatingsForMovie, "notes: ")
recap.MovieUppernbLimit.Ratings = recap.Movies[recap.Movies$nb.Ratings >= nbLimit.RatingsForMovie,]
order.BestMoviesUppernbLimit.Ratings = order(recap.MovieUppernbLimit.Ratings$mean, decreasing = TRUE)
for (movie in 1:nb.BestMovies){
  id.order = order.BestMoviesUppernbLimit.Ratings[movie]
  cat("Le film d'ID", recap.MovieUppernbLimit.Ratings$movieID[id.order], ",",
      as.character(data.Movies$title[recap.MovieUppernbLimit.Ratings$movieID[id.order]]),
      "a une note moyenne de", recap.MovieUppernbLimit.Ratings$mean[id.order], "sur",
      recap.MovieUppernbLimit.Ratings$nb.Ratings[id.order], "votes.")
  cat("\n")
}

## Films ayant les pires notes

nb.WorstMovies = 10
order.WorstMovies <- order(recap.Movies$mean, decreasing = FALSE)
cat("Les", nb.WorstMovies, "pires films : ")
for (movie in 1:nb.WorstMovies){
  id.order = order.WorstMovies[movie]
  cat("Le film d'ID", recap.Movies$movieID[id.order], ",", 
      as.character(data.Movies$title[recap.Movies$movieID[id.order]]),
      ",a une note moyenne de", recap.Movies$mean[id.order], "sur",
      recap.Movies$nb.Ratings[id.order], "vote(s).")
  cat("\n")
}

## Films ayant une note moyenne de 1

cat("Il y a", sum(recap.Movies$mean == 1), "films qui ont reÃ§u une note moyenne de 1.")

## Films ayant les pires notes et dÃ©passant un seuil de visionnage

cat("Les", nb.WorstMovies, "pires films ayant reÃ§u plus de", nbLimit.RatingsForMovie, "notes: ")
recap.MovieUppernbLimit.Ratings = recap.Movies[recap.Movies$nb.Ratings >= nbLimit.RatingsForMovie,]
order.WorstMoviesUppernbLimit.RatingsForMovie = order(recap.MovieUppernbLimit.Ratings$mean, decreasing = FALSE)
for (movie in 1:nb.WorstMovies){
  id.order = order.WorstMoviesUppernbLimit.RatingsForMovie[movie]
  cat("Le film d'ID", recap.MovieUppernbLimit.Ratings$movieID[id.order], ",",
      as.character(data.Movies$title[recap.MovieUppernbLimit.Ratings$movieID[id.order]]),
      "a une note moyenne de", recap.MovieUppernbLimit.Ratings$mean[id.order], "sur",
      recap.MovieUppernbLimit.Ratings$nb.Ratings[id.order], "votes.")
  cat("\n")
}

#7.3# SUR LES UTILISATEURS (PAR RAPPORT AU NOMBRE DE NOTES DONNEES)

## Utilisateurs ayant le plus votÃ©

nb.MostVotedUsers = 10
order.MostVotedUsers = order(recap.Users$nb.Ratings, decreasing =TRUE)
cat("Les", nb.MostVotedUsers, "utilisateurs ayant notÃ©s le plus de films : ")
for (user in 1:nb.MostVotedUsers){
  id.order = order.MostVotedUsers[user]
  cat("L'utilisateur d'ID", recap.Users$userID[id.order], "a votÃ©", 
      recap.Users$nb.Ratings[id.order], "fois.")
  cat("\n")
}

## Utilisateurs ayant le moins votÃ©

nb.LessVotedUsers = 15
order.LessVotedUsers = order(recap.Users$nb.Ratings, decreasing =FALSE)
cat("Les", nb.LessVotedUsers, "utilisateurs ayant notÃ©s le moins de films : ")
for (user in 1:nb.LessVotedUsers){
  id.order = order.LessVotedUsers[user]
  cat("L'utilisateur d'ID", recap.Users$userID[id.order], "n'a votÃ© que", 
      recap.Users$nb.Ratings[id.order], "fois.")
  cat("\n")
}

## Utilisateurs n'ayant votÃ© que 20 fois

cat("Il y a", sum(recap.Users$nb.Ratings == 20), "utilisateurs qui n'ont votÃ© que 20 fois.")

## Utilisateurs ayant votÃ© moins de xxx fois
nbLimit.RatingsForUser = 75
cat("Il y a", sum(recap.Users$nb.Ratings <= nbLimit.RatingsForUser), "utilisateurs qui ont votÃ© moins de", 
    nbLimit.RatingsForUser, "fois.")

#7.4# SUR LES UTILISATEURS (PAR RAPPORT A LA MOYENNE DES NOTES)

## Utilisateurs ayant donnÃ©s les plus hautes notes

nb.NicestUsers = 20
order.NicestUsers <- order(recap.Users$mean, decreasing = TRUE)
cat("Les", nb.NicestUsers, "utilisateurs les plus gentils : ")
for (user in 1:nb.NicestUsers){
  id.order = order.NicestUsers[user]
  cat("L'utilisateur d'ID", recap.Users$userID[id.order], "a une donnÃ© en moyenne une note de", 
      recap.Users$mean[id.order], "pour", recap.Users$nb.Ratings[id.order], "notes.")
  cat("\n")
}

## Utilisateurs ayant donnÃ© les meilleurs notes et dÃ©passant un seuil de participation

cat("Les", nb.NicestUsers, "utilisateurs ayant donnÃ©es les meilleurs notes et ayant votÃ© plus de", nbLimit.RatingsForUser, "fois: ")
recap.UserUppernbLimit.Ratings = recap.Users[recap.Users$nb.Ratings >= nbLimit.RatingsForUser,]
order.NicestUsersUppernbLimit.Ratings = order(recap.UserUppernbLimit.Ratings$mean, decreasing = TRUE)
for (user in 1:nb.NicestUsers){
  id.order = order.NicestUsersUppernbLimit.Ratings[user]
  cat("L'utilisateur d'ID", recap.UserUppernbLimit.Ratings$userID[id.order], 
      "a donnÃ© en moyenne une note de", recap.UserUppernbLimit.Ratings$mean[id.order], 
      "pour", recap.UserUppernbLimit.Ratings$nb.Ratings[id.order], "notes.")
  cat("\n")
}

## Utilisateurs ayant donnÃ©s les plus faibles notes

nb.MeanestUsers = 20
order.MeanestUsers = order(recap.Users$mean, decreasing = FALSE)
cat("Les", nb.MeanestUsers, "utilisateurs les plus mÃ©chants : ")
for (user in 1:nb.MeanestUsers){
  id.order = order.MeanestUsers[user]
  cat("L'utilisateur d'ID", recap.Users$userID[id.order], "a donnÃ© en moyenne une note de", 
      recap.Users$mean[id.order], "pour", recap.Users$nb.Ratings[id.order], "notes.")
  cat("\n")
}

## Utilisateurs ayant donnÃ© les pires notes et dÃ©passant un seuil de participation

cat("Les", nb.MeanestUsers, "utilisateurs ayant donnÃ©es les pires notes et ayant votÃ© plus de", nbLimit.RatingsForUser, "fois: ")
recap.UserUppernbLimit.Ratings = recap.Users[recap.Users$nb.Ratings >= nbLimit.RatingsForUser,]
order.MeanestUsersUppernbLimit.Ratings = order(recap.UserUppernbLimit.Ratings$mean, decreasing = FALSE)
for (user in 1:nb.MeanestUsers){
  id.order = order.MeanestUsersUppernbLimit.Ratings[user]
  cat("L'utilisateur d'ID", recap.UserUppernbLimit.Ratings$userID[id.order], 
      "a donne en moyenne une note de", recap.UserUppernbLimit.Ratings$mean[id.order], 
      "pour", recap.UserUppernbLimit.Ratings$nb.Ratings[id.order], "notes.")
  cat("\n")
}

# ======================================== 8.ETUDE PAR AGE =================================================



# ====================================== 9.ETUDE PAR SEXE =================================================

## CrÃ©ation des bases par sexe

data.MaleUsers = data.Users[data.Users$gender == "M" ,]
data.FemaleUsers = data.Users[data.Users$gender == "F" ,]

recap.MaleUser = recap.Users[recap.Users$userID %in% data.MaleUsers$userID,]
recap.FemaleUser = recap.Users[recap.Users$userID %in% data.FemaleUsers$userID,]

## Statistiques sur la rÃ©partion des notes par sexe

summary(recap.MaleUser)
summary(recap.FemaleUser)

# ====================================== 10.ETUDE PAR GENRE DE FILMS ========================================

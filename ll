using System;
using System.Collections.Generic;

public enum GameMode
{
    Standard,
    Training,
    SinglePlayerRated
}

// Фабрика для створення об'єктів гри
public static class GameFactory
{
    public static Game CreateGame(GameAccount player1, GameAccount player2, GameMode mode)
    {
        return new Game(player1, player2, mode);
    }
}

public class Game
{
    private static Random random = new Random();
    public GameAccount Player1 { get; private set; }
    public GameAccount Player2 { get; private set; }
    public int GameId { get; private set; }
    public GameMode Mode { get; private set; }

    public Game(GameAccount player1, GameAccount player2, GameMode mode)
    {
        Player1 = player1;
        Player2 = player2;
        GameId = random.Next(100, 999); // Генеруємо унікальний ID гри
        Mode = mode;
    }

    private bool IsGameOver(int player1Score, int player2Score)
    {
        return (player1Score >= 11 || player2Score >= 11) && Math.Abs(player1Score - player2Score) >= 2;
    }

    public int GetRatingChange(GameAccount player)
    {
        if (Mode == GameMode.SinglePlayerRated && player == Player1)
        {
            return 5;
        }

        if (Mode == GameMode.Training)
        {
            return 0; // Рейтинг не змінюється для тренувальної гри
        }

        return 5; // Рейтинг змінюється на 5 для стандартного режиму
    }

    public void PlayGame()
    {
        int player1Score = 0;
        int player2Score = 0;

        // Імітація процесу гри
        while (!IsGameOver(player1Score, player2Score))
        {
            if (random.Next(2) == 0)
            {
                player1Score++;
            }
            else
            {
                player2Score++;
            }

            Console.WriteLine($"Score: {Player1.UserName} {player1Score} - {Player2.UserName} {player2Score}");
        }

        // Результати гри
        if (Mode == GameMode.Training)
        {
            Console.WriteLine("Training game, no rating changes.");
            Player1.RecordGameResult(Player2.UserName, "Training", player1Score, GameId, Mode);
            Player2.RecordGameResult(Player1.UserName, "Training", player2Score, GameId, Mode);
            return;
        }

        if (player1Score > player2Score)
        {
            Player1.WinGame(Player2.UserName, player1Score, GameId, this);
            Player2.LoseGame(Player1.UserName, player2Score, GameId, this);
        }
        else
        {
            Player2.WinGame(Player1.UserName, player2Score, GameId, this);
            Player1.LoseGame(Player2.UserName, player1Score, GameId, this);
        }
    }
}

public class GameAccount
{
    public string UserName { get; private set; }
    public int CurrentRating { get; private set; }
    private List<GameResult> gamesHistory;

    public GameAccount(string username, int initialRating = 10)
    {
        UserName = username;
        CurrentRating = initialRating;
        gamesHistory = new List<GameResult>();
    }

    public void RecordGameResult(string opponentName, string result, int rounds, int gameId, GameMode mode)
    {
        gamesHistory.Add(new GameResult(opponentName, result, rounds, gameId, mode, CurrentRating));
    }

    public void WinGame(string opponentName, int roundsWon, int gameId, Game game)
    {
        int ratingChange = game.GetRatingChange(this);
        CurrentRating += ratingChange;
        gamesHistory.Add(new GameResult(opponentName, "Win", roundsWon, gameId, game.Mode, CurrentRating));
        Console.WriteLine($"{UserName} won against {opponentName} in game #{gameId} and gained {ratingChange} rating points.");
    }

    public void LoseGame(string opponentName, int roundsLost, int gameId, Game game)
    {
        int ratingChange = game.GetRatingChange(this);
        CurrentRating -= ratingChange;
        gamesHistory.Add(new GameResult(opponentName, "Lose", roundsLost, gameId, game.Mode, CurrentRating));
        Console.WriteLine($"{UserName} lost to {opponentName} in game #{gameId} and lost {ratingChange} rating points.");
    }

    public void GetStats()
    {
        Console.WriteLine($"\nStats for {UserName}:");
        Console.WriteLine("Game ID\t\tOpponent\tResult\t\tRounds\t\tRating\t\tGame Mode");

        foreach (var game in gamesHistory)
        {
            Console.WriteLine($"{game.GameId}\t\t{game.OpponentName}\t\t{game.Result}\t\t{game.Rounds}\t\t{game.Rating}\t\t{game.Mode}");
        }

        Console.WriteLine($"\nCurrent Rating: {CurrentRating}");
    }
}

public class GameResult
{
    public string OpponentName { get; private set; }
    public string Result { get; private set; }
    public int Rounds { get; private set; }
    public int GameId { get; private set; }
    public GameMode Mode { get; private set; }
    public int Rating { get; private set; }

    public GameResult(string opponentName, string result, int rounds, int gameId, GameMode mode, int rating)
    {
        OpponentName = opponentName;
        Result = result;
        Rounds = rounds;
        GameId = gameId;
        Mode = mode;
        Rating = rating;
    }
}

public class Program
{
    public static void Main()
    {
        List<GameAccount> players = new List<GameAccount>
        {
            new GameAccount("Lolli"),
            new GameAccount("Molli"),
            new GameAccount("Charlie"),
            new GameAccount("Diana"),
            new GameAccount("Marin")
        };

        while (true)
        {
            Console.WriteLine("Choose a game mode:\n1 - Standard Game\n2 - Training Game\n3 - Single Player Rated\n4 - Random Game Mode\n5 - Exit");
            int choice = int.Parse(Console.ReadLine());

            if (choice == 5) break;

            GameMode mode;
            switch (choice)
            {
                case 1:
                    mode = GameMode.Standard;
                    break;
                case 2:
                    mode = GameMode.Training;
                    break;
                case 3:
                    mode = GameMode.SinglePlayerRated;
                    break;
                case 4:
                    mode = (GameMode)new Random().Next(0, 3);
                    break;
                default:
                    Console.WriteLine("Invalid choice.");
                    continue;
            }

            // Запуск нових ігор
            for (int i = 0; i < players.Count; i++)
            {
                for (int j = i + 1; j < players.Count; j++)
                {
                    Game game = GameFactory.CreateGame(players[i], players[j], mode);
                    game.PlayGame();
                }
            }

            // Виведення статистики
            foreach (var player in players)
            {
                player.GetStats();
            }
        }
    }
}

<Query Kind="Program">
  <Namespace>System.Threading.Tasks</Namespace>
</Query>



//#define LOG_DETAILED
#define RUN_IN_PARALLEL
#define USE_REAL_TIME

static float[] ELITE_TIER_VALUE_MULTIPLIER = { 1.0f, 6f, 36f };
const float TOO_CHEAP_COEFF = 6;
static Random g_random = new Random();
static int NUMBER_OF_RUNS = 1000;
static float SECONDS_TOTAL = (240.0f - 60.0f) / 2.5f;
static float TIME_SCALE = 1000.0f;
const float SIXTY_FPS = 1.0f / 60.0f;
const int DIFF_COUNT = 6;
	
int[,] tierSpawnCounts = new int[NUMBER_OF_RUNS, 3];

async void Main()
{
	void Run(int run, float playerDiff, float durationSeconds, float timeScale)
	{
		var durationMilliseconds = (durationSeconds * 1000.0f) / timeScale;
		var lastTime = 0.0f;

		var card = new Card();
		card.m_cost = 10;
		card.m_tierCount = 3;
		
		var deck = new Deck();
		deck.m_cards.Add(card);
		
		//var night = 1;
		//var nightsSurvived = 0;
		//var daysSurvived = 1;
		
		var night = 16;
		var nightsSurvived = 15;
		var daysSurvived = 16;
		
		var gameProgressCoeff = (daysSurvived * 0.5f + nightsSurvived) * 0.5f;
		var playerDiffCoeff = GetGeneralDifficultyCoeff(gameProgressCoeff, playerDiff);
		var creditsOnActivation = 25 + ((float)Math.Floor(night / 5f) + 1) * 25.0f * playerDiffCoeff ;

		var spawnDirector = new SpawnDirector();
		spawnDirector.m_deck = deck;
		spawnDirector.m_difficultyCoeff = playerDiffCoeff;
		spawnDirector.m_creditsMultiplier = playerDiff + 1.0f;
		spawnDirector.m_creditsOnActivation = creditsOnActivation;
		spawnDirector.m_intervalBetweenWavesMin = 2.0f;
		spawnDirector.m_intervalBetweenWavesMax = 5.0f;
		spawnDirector.m_intervalDuringWavesMin = 0.1f;
		spawnDirector.m_intervalDuringWavesMax = 1.0f;
		spawnDirector.m_maxAliveCount = 10;
		spawnDirector.m_maxSpawnCount = int.MaxValue;
		spawnDirector.m_killTimerMin = (int)(10000.0f / timeScale);
		spawnDirector.m_killTimerMax = (int)(20000.0f / timeScale);
		spawnDirector.Reset();
		
#if USE_REAL_TIME

		var stopwatch = new Stopwatch();
		stopwatch.Start();
#endif
		
		var time = 0.0f;
		
		while (time < durationMilliseconds)
		{
#if USE_REAL_TIME
			time = stopwatch.ElapsedMilliseconds;
			var dt = ((time - lastTime) / 1000.0f) * timeScale;
			if (dt == 0.0f)
				continue;
			lastTime = time;
#else
			var dt = 0.0167f * timeScale;
			time += dt * 1000;
#endif

			do
			{
				var subDt = Math.Min(dt, SIXTY_FPS);
				spawnDirector.Step(subDt);
				dt -= subDt;
			}
			while (dt > SIXTY_FPS);
		}

		for (var i = 0; i < 3; ++i)
		{
			var c = spawnDirector.m_tierSpawnedCounts[i];
			tierSpawnCounts[run, i] = c;
#if LOG_DETAILED
			Console.WriteLine($"Run {run} - Tier {i}: {c} ({p * 100.0f}%)");
#endif
		}
	
	}
	
	var totalSpawnedByDiff = new int[DIFF_COUNT];
	var totalSpawnedByTierByDiff = new int[DIFF_COUNT, 3];
	
	for (var d = 0; d < DIFF_COUNT; ++d)
	//var d = 1;
	{
		var diff = d == 0 ? 0.5f : d;
		
		Console.WriteLine($"=== Difficulty: {diff} ===");
		
#if RUN_IN_PARALLEL	
		var tasks = Enumerable.Range(0, NUMBER_OF_RUNS).Select(i => Task.Run(() => Run(i, diff, SECONDS_TOTAL, TIME_SCALE)));
		await Task.WhenAll(tasks);
#else
		for (var i = 0; i < NUMBER_OF_RUNS; ++i)
		{
			Run(i, diff, SECONDS_TOTAL, TIME_SCALE);
		}
#endif

		for (int i = 0; i < NUMBER_OF_RUNS; ++i)
		{
			totalSpawnedByDiff[d] += tierSpawnCounts[i, 0];
			totalSpawnedByTierByDiff[d, 0] += tierSpawnCounts[i, 0];
			
			totalSpawnedByDiff[d] += tierSpawnCounts[i, 1];
			totalSpawnedByTierByDiff[d, 1] += tierSpawnCounts[i, 1];
			
			totalSpawnedByDiff[d] += tierSpawnCounts[i, 2];
			totalSpawnedByTierByDiff[d, 2] += tierSpawnCounts[i, 2];
		}

		for (int i = 0; i < 3; ++i)
		{
			var avg = totalSpawnedByTierByDiff[d, i] / NUMBER_OF_RUNS;
			var p = totalSpawnedByTierByDiff[d, i] / (float)totalSpawnedByDiff[d];
			Console.WriteLine($"Final Tier {i}: {totalSpawnedByTierByDiff[d, i]} Avg: {avg} ({(int)Math.Round(p * 100)}%)");
		}
	}
		
	Console.WriteLine("done");
}

static float GetGeneralDifficultyCoeff(float gameProgress, float difficulty)
{
    return 1f + gameProgress * difficulty * 0.65f;
}

static float Lerp(float min, float max, float value)
{
	return min + (max - min) * value;
}

class Card
{
	public int m_cost;
	public int m_tierCount;
	
	public virtual float GetTierValueMultiplier(int tier)
	{
		return ELITE_TIER_VALUE_MULTIPLIER[tier];
	}
	
	public CardInstance GetHighestAffordableTier(float credits)
	{
		var selectedTier = 0;
		var selectedCost = 0;
		var foundValidTier = false;
		
		var baseCost = m_cost;
		var tierCount = m_tierCount;
	
		for (var tier = m_tierCount - 1; tier >= 0; --tier)
		{
			var tierCost = (int)(GetTierValueMultiplier(tier) * baseCost);
			if (credits >= tierCost)
			{
				selectedTier = tier;
				selectedCost = tierCost;
				foundValidTier = true;
				break;
			}
		}
		
		if (!foundValidTier)
			return CardInstance.Invalid;
	
		return new CardInstance(this, selectedTier, selectedCost);
	}
}

struct CardInstance
{
	public static readonly CardInstance Invalid = new CardInstance(null, 0, 0);

	public Card card;
	public int tier;
	public int cost;
	
	public CardInstance(Card card, int tier, int cost)
	{
		this.card = card;
		this.tier = tier;
		this.cost = cost;
	}
}


class Deck
{
	public List<Card> m_cards = new List<Card>();

	public Card GetMostExpensiveCard()
	{
		return m_cards.OrderBy(card => card.m_cost).FirstOrDefault();
	}

	public Card DrawCard()
	{
		return m_cards.Skip(g_random.Next(0, m_cards.Count)).FirstOrDefault();		
	}
}

class SpawnDirector
{
	public Deck m_deck;

	public float m_difficultyCoeff = 1.0f;

	public float m_creditsGenTimer = 1.0f;
	public float m_processTimer = 0.0f;
	public float m_processInterval = 0.1f;
	public float m_spawnTimer = 0.0f;

	public float m_credits = 0.0f;
	public float m_creditsMultiplier = 1.0f;
	public float m_creditsOnActivation = 0.0f;

	public float m_intervalBetweenWavesMin = 2.0f;
	public float m_intervalBetweenWavesMax = 5.0f;

	public float m_intervalDuringWavesMin = 0.1f;
	public float m_intervalDuringWavesMax = 1.0f;

	public int m_aliveCount = 0;
	public int m_maxAliveCount = int.MaxValue;
	
	public int m_spawnCount = 0;
	public int m_maxSpawnCount = int.MaxValue;
	
	public int m_kills = 0;
	
	public Random m_random = new Random();
	
	public bool m_lastActivationSucceeded = false;
	
	public CardInstance m_selectedCard;
	
	public int[] m_tierSpawnedCounts = new int[3];
	
	public int m_killTimerMin;
	public int m_killTimerMax;
	
	public void Reset()
	{
		m_creditsGenTimer = 0;
		m_processTimer = 0;
		m_spawnTimer = 0;
		m_credits = m_creditsOnActivation;
		m_aliveCount = 0;
		m_spawnCount = 0;
		m_lastActivationSucceeded = false;
		m_selectedCard = CardInstance.Invalid;
		m_kills = 0;
		
		for (var i = 0; i < 3; ++i)
		{
			m_tierSpawnedCounts[i] = 0;
		}
	}
	
	public void Step(float dt)
	{
		m_creditsGenTimer -= dt;
		if (m_creditsGenTimer <= 0.0f)
		{
			m_creditsGenTimer += 1.0f;
			GenerateCredits();
		}
		
		m_processTimer -= dt;
		if (m_processTimer <= 0.0f)
		{
			m_processTimer += m_processInterval;
			Process(m_processInterval);
		}
	}

	void GenerateCredits()
	{
		m_credits += m_creditsMultiplier * (1.0f + 0.4f * m_difficultyCoeff);
#if LOG_DETAILED
		Console.WriteLine($"Gen Credits: {m_credits}");
#endif
	}
	
	void Process(float dt)
	{
		m_spawnTimer = Math.Max(m_spawnTimer - dt, 0.0f);
		
		if (m_spawnTimer > 0)
			return;
			
		m_lastActivationSucceeded = false;
		
		if (!canDrawCard())
		{
#if LOG_DETAILED
			Console.WriteLine("Spawn Failed: cannot draw card");
#endif
			restartTimerBetweenWaves();
			return;
		}
		
		if (!m_lastActivationSucceeded)
		{
			var card = m_deck.DrawCard();		
			m_selectedCard = card.GetHighestAffordableTier(m_credits);
		}

		if (m_selectedCard.card == null)
		{
#if LOG_DETAILED
			Console.WriteLine("Spawn Failed: too expensive");
#endif
			restartTimerBetweenWaves();
			return;
		}
			
		while (m_selectedCard.tier > 0 && m_credits < m_selectedCard.cost)
		{
			m_selectedCard.tier = m_selectedCard.tier - 1;
			m_selectedCard.cost = (int)(ELITE_TIER_VALUE_MULTIPLIER[m_selectedCard.tier] * m_selectedCard.card.m_cost);
		}
		
		if (m_selectedCard.tier == 0 && m_credits < m_selectedCard.cost)
		{
#if LOG_DETAILED
			Console.WriteLine("Spawn Failed: too expensive");
#endif
			restartTimerBetweenWaves();
			return;
		}
		
		if (m_credits > m_selectedCard.cost * TOO_CHEAP_COEFF &&
			m_selectedCard.card != m_deck.GetMostExpensiveCard())
		{
#if LOG_DETAILED
			Console.WriteLine("Spawn Failed: too cheap");
#endif
			restartTimerBetweenWaves();
			return;
		}
		
		m_lastActivationSucceeded = true;
		m_credits -= m_selectedCard.cost;
		
		m_aliveCount++;
		m_spawnCount++;
		
		var killTime = m_random.Next(m_killTimerMin, m_killTimerMax);
		var killTimer = new System.Timers.Timer(killTime);
		killTimer.AutoReset = false;
		killTimer.Elapsed += (_, _) =>
		{
			int aliveCount;
			int kills;
			lock (this)
			{
				aliveCount = m_aliveCount--;
				kills = m_kills++;
			}
#if LOG_DETAILED
			Console.WriteLine($"=========> Killed zombie - alive {aliveCount} - total kills {kills}");
#endif
		};
		killTimer.Start();
		
		m_tierSpawnedCounts[m_selectedCard.tier]++;
		
#if LOG_DETAILED
		Console.WriteLine($"=========> Spawned tier {m_selectedCard.tier} zombie for {m_selectedCard.cost} credits - alive {m_aliveCount} - spawned {m_spawnCount}");
#endif
		
		if (m_lastActivationSucceeded)
			restartTimerDuringWaves();
		else
			restartTimerBetweenWaves();		
	}
	
	bool canDrawCard()
	{
		return m_aliveCount < m_maxAliveCount && m_spawnCount < m_maxSpawnCount;
	}
	
	void restartTimerBetweenWaves()
	{
		m_spawnTimer += Lerp(m_intervalBetweenWavesMin, m_intervalBetweenWavesMax, m_random.NextSingle());
#if LOG_DETAILED
		Console.WriteLine($"Starting new wave in {m_spawnTimer}s");
#endif
	}
	
	void restartTimerDuringWaves()
	{
		m_spawnTimer += Lerp(m_intervalDuringWavesMin, m_intervalDuringWavesMax, m_random.NextSingle());
#if LOG_DETAILED
		Console.WriteLine($"Spawning in {m_spawnTimer}s");
#endif
	}
}
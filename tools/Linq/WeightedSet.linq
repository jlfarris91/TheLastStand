<Query Kind="Program" />

void Main()
{
	Console.WriteLine("Small");
	test(64, 24, 8, 2);
	test(36, 32, 12, 6);

	Console.WriteLine();
	Console.WriteLine("Medium");
	test(60, 32, 14, 4);
	test(32, 32, 18, 8);

	Console.WriteLine();
	Console.WriteLine("Large");
	test(56, 40, 20, 6);
	test(28, 32, 24, 10);
}

void test(float common, float rare, float epic, float legendary)
{
	var set = new WeightedSet<string>();
	set.Add("common", common);
	set.Add("rare", rare);
	set.Add("epic", epic);
	set.Add("legendary", legendary);
	
	Console.Write($"common={(int)(set.GetChance("common")*100.0)}% ");
	Console.Write($"rare={(int)(set.GetChance("rare")*100.0)}% ");
	Console.Write($"epic={(int)(set.GetChance("epic")*100.0)}% ");
	Console.WriteLine($"legendary={(int)(set.GetChance("legendary")*100.0)}%");
}

// You can define other methods, fields, classes and namespaces here
class WeightedSet<T> where T : class
{
	private static readonly Random s_random = new Random();
	private List<Entry> m_items = new List<Entry>();
	private float m_totalWeight;
	
	public void Add(T item, float weight)
	{
		m_items.Add(new Entry { m_value = item, m_weight = weight });
		m_totalWeight += weight;
	}
	
	public T GetRandom(float weight)
	{
		return GetEntry(weight)?.m_value;
	}
	
	public T GetRandom()
	{
		return GetRandom((float)s_random.NextDouble() * m_totalWeight);
	}
	
	public float GetChance(T item)
	{
		var entry = m_items.FirstOrDefault(entry => entry.m_value == item);
		return entry != null ? entry.m_weight / m_totalWeight : 0.0f;
	}
	
	private Entry GetEntry(float weight)
	{
		var r = weight;
		for (var i = 0; i < m_items.Count(); ++i)
		{
			if (r >= 0.0f && r <= m_items[i].m_weight)
			{
				return m_items[i];
			}
			r -= m_items[i].m_weight;
		}
		return null;
	}

	private class Entry
	{
		public T m_value;
		public float m_weight;
	}

}
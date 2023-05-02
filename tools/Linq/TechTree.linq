<Query Kind="Program" />

void Main()
{
	var headquarters1 = new Unit("Headquarters 1");
	var headquarters2 = new Unit("Headquarters 2");
	var headquarters3 = new Unit("Headquarters 3");
	var headquarters4 = new Unit("Headquarters 4");
	var headquarters5 = new Unit("Headquarters 5");
	var headquarters6 = new Unit("Headquarters 6");
	
	var builder = new Unit("Builder");
	var militia = new Unit("Militia");
	var spearman = new Unit("Spearman");
	var marksman = new Unit("Marksman");
	var medic = new Unit("Medic");
	
	var workbench = new Unit("Workbench");
	var workshop = new Unit("Workshop");
	
	var armory = new Unit("Armory");
	var spearmansTent = new Unit("Spearman's Tent");
	var aidStation = new Unit("Aid Station");
	
	var militiaAttackDamage = new Research("Militia Attack Damage");
	var militiaAttackSpeed = new Research("Militia Attack Speed");
	var militiaArmor = new Research("Militia Armor");
	
	var spearmanAttackDamage = new Research("Spearman Attack Damage");
	var spearmanAttackSpeed = new Research("Spearman Attack Speed");
	var spearmanArmor = new Research("Spearman Armor");
	
	var marksmanAttackDamage = new Research("Marksman Attack Damage");
	var marksmanRange = new Research("Marksman Range");
}

class TechTreeItem
{
	public TechTreeItem(string name)
	{
		Name = name;
	}
	string Name { get; set; }
	List<TechTreeItem> Requirements { get; } = new List<TechTreeItem>();
};

class Unit : TechTreeItem
{
	public Unit(string name) : base(name)
	{
	}
	List<Research> ResearchAvailable { get; } = new List<Research>();
	List<Unit> UnitsAvailable { get; } = new List<Unit>();
	List<TechTreeItem> ItemsAvailable { get; } = new List<TechTreeItem>();
	List<Unit> UpgradesTo { get; } = new List<Unit>();
};

class Research : TechTreeItem
{
	public Research(string name) : base(name)
	{
	}
};